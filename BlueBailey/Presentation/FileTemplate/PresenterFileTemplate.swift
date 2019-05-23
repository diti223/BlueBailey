//
//  FileName.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/21/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class PresenterFileTemplate: MVPFileTemplate {
    static let viewDidLoadMethod: String =
    """
        func viewDidLoad() {
            
        }
    """
    init(moduleName: String, methodDefinitions: String = PresenterFileTemplate.viewDidLoadMethod, project: XcodeProj) {
        super.init(moduleName: moduleName, methodDefinitions: methodDefinitions, componentName: MVPComponent.presenter.name, project: project, frameworks: ["Foundation"])
        fileType = .class
    }
    
    override var string: String {
        let viewInterfaceName = "\(moduleName)\(MVPComponent.view.name)"
        let navigationInterfaceName = "\(moduleName)\(MVPComponent.navigation.name)"
        return super.string +
        """
        
        \(String.init(describing: fileType)) \(fileName) {
            private weak var view: \(viewInterfaceName)?
            private let navigation: \(navigationInterfaceName)
            private let useCaseFactory: UseCaseFactory
        
            init(view: \(viewInterfaceName), navigation: \(navigationInterfaceName), useCaseFactory: UseCaseFactory) {
                self.view = view
                self.navigation = navigation
                self.useCaseFactory = useCaseFactory
            }
        
        \(methodDefinitions)
        }
        
        """
    }
}
