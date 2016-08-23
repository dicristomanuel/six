//
//  AppDelegate.swift
//  six
//
//  Created by Manuel Di Cristo on 8/22/16.
//  Copyright © 2016 six. All rights reserved.
//

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

   func applicationDidFinishLaunching(aNotification: NSNotification) {
     NSEvent.addGlobalMonitorForEventsMatchingMask(NSKeyDownMask, handler: {(e: NSEvent) -> Void in
       print("\(e)")
     })
   }
  }

  func applicationWillTerminate(aNotification: NSNotification) {}

  func showMenu(sender: NSStatusBarButton) {
    print("Menu is open")
  }

  func quit(send: AnyObject?) {
    NSApplication.sharedApplication().terminate(nil)
  }

}
