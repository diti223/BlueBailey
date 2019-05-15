//
//  NavigatorConnector.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import PathKit

class NavigatorConnector {
    private let projectPath: Path
    private let useCaseFactory: UseCaseFactory
    private weak var viewController: NavigatorViewController?
    
    init(useCaseFactory: UseCaseFactory, projectPath: Path) {
        self.projectPath = projectPath
        self.useCaseFactory = useCaseFactory
    }
    
    func assemble(viewController: NavigatorViewController) throws {
        self.viewController = viewController
        let presenter = try NavigatorPresenter(view: viewController, navigation: self, useCaseFactory: useCaseFactory, path: projectPath)
        viewController.presenter = presenter
    }
    
}


extension NavigatorConnector: NavigatorNavigation {
    
}
