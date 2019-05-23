//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class NavigationFileTemplate: MVPFileTemplate {
    init(moduleName: String, methodDefinitions: String, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.navigation.name, project: project, frameworks: ["Foundation"])
        fileType = .protocol
    }
    
    override var string: String {
        let navigationInterfaceName = "\(moduleName)\(MVPComponent.navigation.name)"
        return super.string +
        """
        
        \(String.init(describing: fileType)) \(navigationInterfaceName): class {
            \(methodDefinitions)
        }
        
        """
    }
}
