//
//  NavigatorPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation
import XcodeProj

class NavigatorPresenter {
    private weak var view: NavigatorView?
    private let navigation: NavigatorNavigation
    private let project: XcodeProj
    private let useCaseFactory: UseCaseFactory
    
    init(view: NavigatorView, navigation: NavigatorNavigation, useCaseFactory: UseCaseFactory, project: XcodeProj) {
        self.view = view
        self.project = project
        self.useCaseFactory = useCaseFactory
        self.navigation = navigation
    }
    
    func viewDidLoad() {
        view?.displayProject(named: project.pbxproj.rootObject?.name ?? "A girl has no name")
    }
    
}
