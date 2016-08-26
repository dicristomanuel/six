import Foundation
import Cocoa
import IOKit
import ChannelZ

@NSApplicationMain
class HidManager: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    // a channel from IOHIDManager to IOHIDValueRefs; it can be filtered, mapped, throttled, etc.
    var iochannel: Channel<IOHIDManager, IOHIDValueRef>!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // creates a new channel to an IOHIDManager
        self.iochannel = channelIOHIDManager()
        
        // add in a channel phase that filters out all events except button events
        let buttonChannel = iochannel.filter({ IOHIDElementGetType(IOHIDValueGetElement($0).takeUnretainedValue()).value == kIOHIDElementTypeInput_Button.value })
        
        
        // add a receiver for button events
        let buttonReceipt = buttonChannel.receive({ (value: IOHIDValueRef) in
            NSLog("button event: \(value)") // mouse button or keyboard (de-)press
        })
        
        // add in a channel phase that filters out all events except misc pointer events
        let mouseChannel = iochannel.filter({ IOHIDElementGetType(IOHIDValueGetElement($0).takeUnretainedValue()).value == kIOHIDElementTypeInput_Misc.value })
        
        // convert the mouse channel into the scaled physical events
        let scaledMouseChannel: Channel<IOHIDManager, Double> = mouseChannel.map({ IOHIDValueGetScaledValue($0, IOHIDValueScaleType(kIOHIDValueScaleTypePhysical)) })
        
        
        // add a receiver for the scaled events
        let scaledMouseReceipt = scaledMouseChannel.receive({ (value: Double) in
            NSLog("scaled mouse physical: \(value)")
        })
        
        // we can also cancel listening when we are done; when all receivers are cancelled, the
        // IOHIDManager will stop running, but it will start up again if anyone new starts listening
        // scaledMouseReceipt.cancel()
    }
}


/// Creates a channel for a IOHIDManagerCreate with the specified devices (defaults to all) in the given runloop (defaults to current); the manager will be opened when someone starts listening, and then will be closed again when the last listener is cancelled
public func channelIOHIDManager(devices: [String : AnyObject] = [:], runloop: CFRunLoop = CFRunLoopGetCurrent())->Channel<IOHIDManager, IOHIDValueRef> {
    
    let ioman = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone)).takeUnretainedValue()
    IOHIDManagerSetDeviceMatching(ioman, devices)
    
    var receivers = ReceiverList<IOHIDValueRef>()
    
    // bounce input value callbacks through a closure in the context pointer and then down to our receivers
    let callback: ChannelZIOValueCallback = { val in receivers.receive(val) }
    IOHIDManagerRegisterInputValueCallback(ioman, channelZIOTrampolineAsCallback(), unsafeBitCast(callback, UnsafeMutablePointer<Void>.self))
    
    // create the channel that will be emit the callback events
    return Channel(source: ioman) { receiver in
        let cb = callback // hang on to the callback; don't let it get released until the Channel is released
        
        if receivers.count == 0 { // someone started listening: start/resume the manager
            IOHIDManagerScheduleWithRunLoop(ioman, runloop, kCFRunLoopDefaultMode)
            IOHIDManagerOpen(ioman, IOOptionBits(kIOHIDOptionsTypeNone))
        }
        
        let index = receivers.addReceiver(receiver)
        
        return ReceiptOf(canceler: {
            receivers.removeReceptor(index)
            if receivers.count == 0 { // no one is listening anymore; pause the manager
                IOHIDManagerUnscheduleFromRunLoop(ioman, runloop, kCFRunLoopDefaultMode)
                IOHIDManagerClose(ioman, IOOptionBits(kIOHIDOptionsTypeNone))
            }
        })
    }
}


// the follow C is a simple trampoline from a callback to a block closure in the context pointer; put it in a trampoline.c file and reference it from the Swift bridging header
#include <IOKit/hid/IOHIDLib.h>

/// The callback function to be received with new values
typedef void (^ChannelZIOValueCallback)(IOHIDValueRef value);

/// Simply forward the UI info through to the context block pointer
void channelZIOTrampoline(void* context, IOReturn result, void* sender, IOHIDValueRef value) {
    ((ChannelZIOValueCallback)context)(value);
}

/// The trampoline cast as something Swift will find palatible to pass through to IOHIDManagerRegisterInputValueCallback
IOHIDValueCallback channelZIOTrampolineAsCallback() { return channelZIOTrampoline; }