//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class ConnectorFileTemplate: PlatformFileTemplate {
    init(moduleName: String, methodDefinitions: String, project: XcodeProj, platform: Platform) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.connector.name, project: project, platform: platform)
        self.fileType = .class
    }
    
    override var string: String {
        let navigationInterfaceName = "\(moduleName)\(MVPComponent.navigation.name)"
        let viewControllerName = "\(moduleName)\(MVPComponent.viewController.name)"
        let presenterName = "\(moduleName)\(MVPComponent.presenter.name)"
        return super.string +
        """
        \(String.init(describing: fileType)) \(fileName) {
        \tlet useCaseFactory: UseCaseFactory
        \tweak var viewController: \(viewControllerName)?
        
        \tinit(useCaseFactory: UseCaseFactory) {
        \t\tself.useCaseFactory = useCaseFactory
        \t}
        
        \tfunc assembleViewController(_ viewController: \(viewControllerName)) {
        \t\tself.viewController = viewController
        \t\tlet presenter = \(presenterName)(view: viewController, navigation: self, useCaseFactory: UseCaseFactory)
        \t\tviewController.presenter = presenter
        \t}
        \t
        \t\(methodDefinitions)
        \t
        }
        
        \(String.init(describing: FileType.extension)) \(fileName): \(navigationInterfaceName) {
        \t
        }
        
        """
    }
}
