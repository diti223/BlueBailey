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
        
        let path = Path("Project/Bait.xcodeproj") // Your project path
        guard let xcodeproj = try? XcodeProj(path: path) else {
                return
        }
        let pbxproj = xcodeproj.pbxproj
        // Returns a PBXProj
        pbxproj.nativeTargets.forEach { target in
            print(target.name)
        }
        let project = pbxproj.projects.first! // Returns a PBXProject
        let mainGroup = project.mainGroup
        try? mainGroup?.addGroup(named: "MyGroup")
        try? xcodeproj.write(path: path)
        var groupPath = Path("Project/MyGroup")
        try? groupPath.mkdir()
        groupPath = groupPath + Path("SubGroup")
        try? groupPath.mkdir()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension XcodeProj {
    
}
