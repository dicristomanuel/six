import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menu = NSMenu()
  var eventMonitor: EventMonitor?

//  func function001()  {
//    let anApplication = NSApplication.sharedApplication()
//    print("Shared Application Object: \(anApplication).")
//  }
//  
//  func function002()  {
//    let anApplication = NSApplication.sharedApplication()
//    let obj = anApplication.delegate
//    print("Delegate Object: \(obj).")
//  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
//    function001()
//    function002()
    setupButton()
    buildMenu()
    setupEventMonitor()
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
    eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask, .KeyDownMask]) { event in
      print(event)
    }
    eventMonitor?.start()
  }

}
