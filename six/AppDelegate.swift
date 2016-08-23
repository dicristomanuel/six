import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    if let button = statusItem.button {
      button.image = NSImage(named: "iconsix")
    }

    menu.addItem(NSMenuItem(title: "Six", action: #selector(AppDelegate.showMenu(_:)), keyEquivalent: "S"))
    menu.addItem(NSMenuItem.separatorItem())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
    statusItem.menu = menu

    let NSKeyDownMask: NSEventMask

    NSEvent.addGlobalMonitorForEventsMatchingMask(NSKeyDownMask, handler: {(event: NSEvent) -> Void in
      print("\(event)")
    })

  }

  func applicationWillTerminate(aNotification: NSNotification) {}

  func showMenu(sender: NSStatusBarButton) {
    print("Menu is open")
  }

  func quit(send: AnyObject?) {
    NSApplication.sharedApplication().terminate(nil)
  }

}
