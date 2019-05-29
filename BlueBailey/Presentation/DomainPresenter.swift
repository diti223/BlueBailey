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
    private let useCaseComponent = UseCaseComponent()

    init(view: DomainView, navigation: DomainNavigation, useCaseFactory: UseCaseFactory, domainNode: Node) {
        self.view = view
        self.navigation = navigation
        self.useCaseFactory = useCaseFactory
        self.domainNode = domainNode
    }

    func viewDidLoad() {
        
    }
    
    func numberOfChildrenOfItem(_ item: Any?) -> Int {
        guard let children = (item as? DomainComponent)?.subComponents else {
            return 0
        }
        
        return children.count
    }
    
    func child(at index: Int, ofItem item: Any?) -> Any {
        guard let children = (item as? DomainComponent)?.subComponents else {
            return useCaseComponent
        }
        
        return children[index]
    }
    
    func isGroup(item: Any) -> Bool {
        return (item as? DomainComponent)?.subComponents != nil
    }
    
    func configure(itemView: DomainComponentView, with item: Any, in section: Section) {
        guard let item = item as? DomainComponent else { return }
        
        switch section {
        case .component:
            guard let itemView = itemView as? DomainComponentItemView else { return }
            itemView.displayName(type(of: item).userDescription)
        case .name:
            guard let itemView = itemView as? DomainComponentNameView else { return }
            itemView.displayName()
            
        case .action:
            guard let itemView = itemView as? DomainComponentActionView else { return }
            
            itemView.displayAddAction()
            
        }
    }
    
    func shouldDisplayView(for item: Any, in section: Section) -> Bool {
        guard section == .action else {
            return true
        }
        return isGroup(item: item)
    }
    
    
}
