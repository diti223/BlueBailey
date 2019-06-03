//
//  NavigatorConnector.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import AppKit
import PathKit

class NavigatorConnector {
    private let projectPath: Path
    private let useCaseFactory: UseCaseFactory
    private weak var viewController: NavigatorViewController?
    
    lazy var domainConnectorInit: ((DomainPresenterDelegate) -> DomainConnector) = {
        let connector = DomainConnector(useCaseFactory: self.useCaseFactory, delegate: $0)
        return connector
    }
    
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
    func navigateToDomain(delegate: DomainPresenterDelegate) {
        guard let destination = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "DomainViewController") as? DomainViewController else { return }
        domainConnectorInit(delegate).assembleViewController(destination)
        
        viewController?.presentAsModalWindow(destination)
    }
}
