import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()
  var eventMonitor: EventMonitor? = nil
  //  var ble = PeripheralWindowController()
  
  var ble = BLEService()

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    setupButton()
    buildMenu()
    setupEventMonitor()
    ble.start()
  }

  func applicationWillTerminate(aNotification: NSNotification) {}

  func showMenu(sender: NSStatusBarButton) {
    print("Menu is open")
  }

  func quit(send: AnyObject?) {
    NSApplication.sharedApplication().terminate(nil)
  }

  func setupButton() {
    if let button = statusItem.button {
      button.image = NSImage(named: "iconsix")
    }
  }

  func buildMenu() {
    menu.addItem(NSMenuItem(title: "Six", action: #selector(AppDelegate.showMenu(_:)), keyEquivalent: "S"))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
    statusItem.menu = menu
  }

  func setupEventMonitor() {
    eventMonitor = EventMonitor(mask: .KeyDownMask) { event in
      print(event)
    }
    eventMonitor?.start()
  }

}
