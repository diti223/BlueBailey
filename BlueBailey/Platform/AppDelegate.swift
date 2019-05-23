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
        guard NSApplication.shared.windows.count <= 2 else { return }
        ViewController.openInitialViewController()
    }

}

extension XcodeProj {
    
}
