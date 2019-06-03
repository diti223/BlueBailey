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
    weak var delegate: DomainPresenterDelegate?

    init(useCaseFactory: UseCaseFactory, delegate: DomainPresenterDelegate) {
        self.useCaseFactory = useCaseFactory
        self.delegate = delegate
    }

    func assembleViewController(_ viewController: DomainViewController) {
        self.viewController = viewController
        let presenter = DomainPresenter(view: viewController, navigation: self, useCaseFactory: useCaseFactory, delegate: delegate)
        viewController.presenter = presenter
    }
}

extension DomainConnector: DomainNavigation {

}
