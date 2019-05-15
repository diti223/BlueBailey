//
//  NavigatorConnector.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class NavigatorConnector {
    private let project: XcodeProj
    private let useCaseFactory: UseCaseFactory
    private weak var viewController: NavigatorViewController?
    
    init(useCaseFactory: UseCaseFactory, project: XcodeProj) {
        self.project = project
        self.useCaseFactory = useCaseFactory
    }
    
    func assemble(viewController: NavigatorViewController) {
        self.viewController = viewController
        let presenter = NavigatorPresenter(view: viewController, navigation: self, useCaseFactory: useCaseFactory, project: project)
        viewController.presenter = presenter
    }
    
}


extension NavigatorConnector: NavigatorNavigation {
    
}
