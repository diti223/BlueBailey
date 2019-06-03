//
//  DomainPresenter.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/23/19
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol DomainPresenterDelegate: class {
    func beginProjectUpdates()
    func endProjectUpdates()
    func createFile(_ name: String, withContent content: String, atRelativePath relativePath: String)
}

class DomainPresenter {
    private weak var view: DomainView?
    private weak var delegate: DomainPresenterDelegate?
    private let navigation: DomainNavigation
    private let useCaseFactory: UseCaseFactory
    private let useCaseComponent = UseCaseComponent()

    init(view: DomainView, navigation: DomainNavigation, useCaseFactory: UseCaseFactory, delegate: DomainPresenterDelegate?) {
        self.view = view
        self.navigation = navigation
        self.useCaseFactory = useCaseFactory
        self.delegate = delegate
    }

    func viewDidLoad() {
        
    }
    
    func numberOfChildrenOfItem(_ item: Any?) -> Int {
        guard let children = (item as? DomainComponent)?.subComponents else {
            return 1
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
            itemView.displaySuggested(item.name)
            
        case .action:
            guard let itemView = itemView as? DomainComponentActionView else { return }
            
            let shouldDisplayAdd = type(of: item).canAddSubComponents
            itemView.displayAddAction(shouldDisplayAdd)
            let shouldDisplayRemove = item.isRemovable
            itemView.displayRemoveAction(shouldDisplayRemove)
        }
    }
    
    func shouldDisplayView(for item: Any, in section: Section) -> Bool {
        guard let item = item as? DomainComponent,
            section == .action else {
            return true
        }
        
        if type(of: item).canAddSubComponents || item.isRemovable {
            return true
        }
        
        return false
    }
    
    func addComponent(for item: Any) {
        guard let item = item as? DomainComponent else { return }
        item.addSubComponent()
        view?.reloadData()
    }
    
    func removeComponent(_ item: Any) {
        guard let item = item as? DomainComponent else { return }
        item.removeFromParent()
        view?.reloadData()
    }
    
    func editName(_ newName: String?, of item: Any) {
        guard let item = item as? DomainComponent else { return }
        item.customName = newName
        view?.reloadData()
    }
    
    func createFiles() {
        delegate?.beginProjectUpdates()
        createFile(for: useCaseComponent)
        delegate?.endProjectUpdates()
    }
    
    private func createFile(for component: DomainComponent) {
        let request = CreateFileRequest(component: component)
        let useCase = CreateComponentContentUseCase(request: request, handler: self)
        useCase.execute()
        if let subComponents = component.subComponents {
            subComponents.forEach { createFile(for: $0) }
        }
    }
}

extension DomainPresenter: CreateFilePresentation {
    func templateNotFound() {
        
    }
    
    func templateFileError(error: Error) {
        
    }
    
    func handleCompletedFile(named: String, content: String, path: String) {
        delegate?.createFile(named, withContent: content, atRelativePath: path)
    }
}
