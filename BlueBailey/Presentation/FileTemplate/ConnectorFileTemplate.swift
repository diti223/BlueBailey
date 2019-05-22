//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class ConnectorFileTemplate: MVPFileTemplate {
    static let viewDidLoadMethod: String =
    """
    func viewDidLoad() {

    }
    """
    init(moduleName: String, methodDefinitions: String, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.presenter.name, project: project)
    }
    
    override var string: String {
        let className = "\(moduleName)\(MVPComponent.connector.name)"
        let navigationInterfaceName = "\(moduleName)\(MVPComponent.navigation.name)"
        return super.string +
        """
        \(String.init(describing: fileType)) \(fileName) {
        \tweak var view: \(viewInterfaceName)?
        \tlet navigation: \(navigationInterfaceName)
        
        \tinit(view: \(viewInterfaceName), navigation: \(navigationInterfaceName)) {
        \tself.view = view
        \tself.navigation = navigation
        \t}
        
        \t\(methodDefinitions)
        }
        
        """
    }
}
