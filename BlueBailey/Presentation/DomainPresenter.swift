//
//  DomainPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

class DomainPresenter {
    private weak var view: DomainView?
    private let navigation: DomainNavigation
    private let useCaseFactory: UseCaseFactory
    private let domainNode: Node

    init(view: DomainView, navigation: DomainNavigation, useCaseFactory: UseCaseFactory, domainNode: Node) {
        self.view = view
        self.navigation = navigation
        self.useCaseFactory = useCaseFactory
        self.domainNode = domainNode
    }

    func viewDidLoad() {
        
    }
}
