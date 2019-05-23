//
//  DomainConnector.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import AppKit

class DomainConnector {
    let useCaseFactory: UseCaseFactory
    weak var viewController: DomainViewController?
    let domainNode: Node

    init(useCaseFactory: UseCaseFactory, domainNode: Node) {
        self.useCaseFactory = useCaseFactory
        self.domainNode = domainNode
    }

    func assembleViewController(_ viewController: DomainViewController) {
        self.viewController = viewController
        let presenter = DomainPresenter(view: viewController, navigation: self, useCaseFactory: useCaseFactory, domainNode: domainNode)
        viewController.presenter = presenter
    }
}

extension DomainConnector: DomainNavigation {

}
