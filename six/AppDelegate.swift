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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "iconsix")
            button.action = Selector("showMenu:")
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    func showMenu(sender: NSStatusBarButton) {
        print("Menu is open")
    }


}

