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
        
//        let projectPath = Path("Project")
//        if !projectPath.exists {
//            try? Path("Project").mkdir()
//        }
//        let path = Path("Project/Bait/Bait.xcodeproj") // Your project path
//        if !path.exists {
//            
//            let data = XCWorkspaceData(children: [])
//            let workspace = XCWorkspace(data: data)
//            let project = PBXProject(name: "Bait", buildConfigurationList: XCConfigurationList.init(buildConfigurations: [], defaultConfigurationName: "Debug", defaultConfigurationIsVisible: true), compatibilityVersion: "1.0", mainGroup: PBXGroup(children: [], sourceTree: nil, name: "Main", path: nil, includeInIndex: nil, wrapsLines: nil, usesTabs: nil, indentWidth: nil, tabWidth: nil))
//            let proj = PBXProj(rootObject: project, objectVersion: 1, archiveVersion: 1, classes: [:], objects: [])
//            let xcodeProj = XcodeProj(workspace: workspace, pbxproj: proj)
//            try? xcodeProj.write(path: path)
//        }
//        
//        guard let xcodeproj = try? XcodeProj(path: path) else {
//            return
//        }
//        let pbxproj = xcodeproj.pbxproj
//        // Returns a PBXProj
//        pbxproj.nativeTargets.forEach { target in
//            print(target.name)
//        }
//        let project = pbxproj.projects.first! // Returns a PBXProject
//        let mainGroup = project.mainGroup
//        try? mainGroup?.addGroup(named: "MyGroup")
//        try? xcodeproj.write(path: path)
//        var groupPath = Path("Project/MyGroup")
//        try? groupPath.mkdir()
//        groupPath = groupPath + Path("SubGroup")
//        try? groupPath.mkdir()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

extension XcodeProj {
    
}
