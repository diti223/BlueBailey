//
//  DomainPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

class DomainPresenter {
    
    struct ItemGroup {
        let items: [Item]
        
    }
    
    class Item {
        let component: DomainComponent
        let name: String
        var isSelected: Bool = true
        var shouldDisplayAddOption: Bool
        init(component: DomainComponent) {
            self.component = component
            self.name = component.name
            self.shouldDisplayAddOption = component.canAddMultipleItems
        }
        
    }
    
    private weak var view: DomainView?
    private let navigation: DomainNavigation
    private let useCaseFactory: UseCaseFactory
    private let domainNode: Node
    private let itemGroups: [ItemGroup]
    
    var numberOfComponents: Int {
        return items.count
    }

    init(view: DomainView, navigation: DomainNavigation, useCaseFactory: UseCaseFactory, domainNode: Node) {
        self.view = view
        self.navigation = navigation
        self.useCaseFactory = useCaseFactory
        self.domainNode = domainNode
        self.itemGroups = DomainComponent.allCases.map { Item(component: $0) }.map { ItemGroup(items: [$0])}
    }

    func viewDidLoad() {
        
    }
    
    func componentTitle(at index: Int) -> String {
        return items[index].name
    }
    
    func numberOfSubcomponents(at index: Int) -> Int {
        return items[
    }
    
}

private extension DomainComponent {
    var name: String {
        return String(describing: self).firstLetterUppercased
    }
    
    var canAddMultipleItems: Bool {
        switch self {
            case .entity, .gateway: return true
            default: return false
        }
    }
}
