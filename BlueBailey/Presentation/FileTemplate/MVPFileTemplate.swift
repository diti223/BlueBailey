//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class MVPFileTemplate: XcodeProjFileTemplate {
    let moduleName: String
    let methodDefinitions: String
    
    init(moduleName: String, methodDefinitions: String, componentName: String, project: XcodeProj, frameworks: [String]) {
        self.methodDefinitions = methodDefinitions
        self.moduleName = moduleName
        super.init(fileName: "\(moduleName)\(componentName)", fileExtension: "swift", project: project, frameworks: frameworks, fileType: .none)
    }
}


class PresentationFileTemplate: MVPFileTemplate {
    init(moduleName: String, methodDefinitions: String, componentName: String, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: componentName, project: project, frameworks: ["Foundation"])
    }
}

//class PlatformFileTemplate: MVPFileTemplate {
//    init(moduleName: String, methodDefinitions: String, componentName: String, project: XcodeProj) {
//        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: componentName, project: project, frameworks: ["UIKit"])
//    }
//}
