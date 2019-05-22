//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class ViewFileTemplate: MVPFileTemplate {
    static let reloadMethod: String =
    """
    func reloadData()
    """
    init(moduleName: String, methodDefinitions: String = ViewFileTemplate.reloadMethod, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.view.name, project: project, frameworks: ["Foundation"])
        fileType = .protocol
    }
    
    override var string: String {
        let viewInterfaceName = "\(moduleName)\(MVPComponent.view.name)"
        return super.string +
        """
        
        \(String.init(describing: fileType)) \(viewInterfaceName): class {
        \t\(methodDefinitions)
        }
        
        """
    }
}
