//
//  DomainPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

class DomainPresenter {
    
//    struct ItemGroup {
//        let component: DomainComponent
//        let items: [Item]
//    }
//
//    class Item {
//        var name: String
//        var isSelected: Bool = true
//        var shouldDisplayAddOption: Bool
//        init(name: String) {
//            self.component = component
//            self.name = component.name
//            self.shouldDisplayAddOption = component.canAddMultipleItems
//        }
//
//    }
    
    private weak var view: DomainView?
    private let navigation: DomainNavigation
    private let useCaseFactory: UseCaseFactory
    private let domainNode: Node
    
    private let useCaseComponent = UseCaseComponent()
//    let itemGroups: [ItemGroup]
    
//    var numberOfComponents: Int {
//        return items.count
//    }

    init(view: DomainView, navigation: DomainNavigation, useCaseFactory: UseCaseFactory, domainNode: Node) {
        self.view = view
        self.navigation = navigation
        self.useCaseFactory = useCaseFactory
        self.domainNode = domainNode
    }

    func viewDidLoad() {
        
    }
    
    func numberOfChildrenOfItem(_ item: Any?) -> Int {
        if let group = item as? ItemGroup {
            return group.items.count
        }
        
        return itemGroups.count
    }
    
    func child(at index: Int, ofItem item: Any?) -> Any {
        if let group = item as? ItemGroup {
            return group.items[index]
        }
        
        return itemGroups[index]
    }
    
    func hasChildren(item: Any) -> Bool {
        if let group = item as? ItemGroup {
            return group.items.count > 0
        }
        
        return false
    }
    
    func isGroup(item: Any) -> Bool {
        if item as? ItemGroup != nil {
            return true
        }
        
        return false
    }
    
    func configure(itemView: Any, with item: Any, at index: Int, in section: Section) {
//        let component = self.itemGroups
//        switch section {
//        case .component:
//            let itemView = itemView as? DomainComponentView
//            if let item = item as? ItemGroup {
//                itemView?.display(name: item.component.name)
//            } else if let item = item as? Item {
//                itemView?.display(name: item.name)
//            }
//        case .name: <#code#>
//        case .action: <#code#>
//        }
    }
    
//    func componentTitle(at index: Int) -> String {
//        return items[index].name
//    }
//    
//    func numberOfSubcomponents(at index: Int) -> Int {
//        return items[
//    }
    
}


