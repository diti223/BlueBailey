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
            let useCaseFactory: UseCaseFactory
            weak var viewController: \(viewControllerName)?
        
        //    lazy var <#nextScene#>ConnectorInit: (() -> <#NextSceneConnector#>) = {
        //        let connector = <#NextSceneConnector#>(useCaseFactory: self.useCaseFactory)
        //        return connector
        //    }

            init(useCaseFactory: UseCaseFactory) {
                self.useCaseFactory = useCaseFactory
            }
        
            func assembleViewController(_ viewController: \(viewControllerName)) {
                self.viewController = viewController
                let presenter = \(presenterName)(view: viewController, navigation: self, useCaseFactory: useCaseFactory)
                viewController.presenter = presenter
            }
        
            \(methodDefinitions)
        
        }
        
        \(String.init(describing: FileType.extension)) \(fileName): \(navigationInterfaceName) {
        
        }
        
        """
    }
}
