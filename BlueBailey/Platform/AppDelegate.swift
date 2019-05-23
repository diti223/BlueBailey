//
//  AppDelegate.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/11/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Cocoa
import XcodeProj
import PathKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: Selector(("didCloseWindow:")), name: NSWindow.willCloseNotification, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @objc func didCloseWindow(_ notification: NSNotification) {
        guard ((notification.object as? NSWindow)?.contentViewController as? ViewController) == nil else { return }
        let openWindows = NSApplication.shared.orderedWindows
        guard openWindows.count <= 2 else { return }
        openWindows.compactMap({ $0.contentViewController as? ViewController}).first?.view.window?.makeKeyAndOrderFront(nil)
//        ViewController.openInitialViewController()
    }

}

extension XcodeProj {
    
}
