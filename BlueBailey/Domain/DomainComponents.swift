//
//  DomainComponents.swift
//  BlueBailey
//
//  Created by Adrian Bilescu on 28/05/2019.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol DomainComponent: class, DomainTemplates {
    static var userDescription: String { get }
    var name: String { get }
    var subComponents: [DomainComponent]? { get }
    static var canAddSubComponents: Bool { get }
    var isRemovable: Bool { get }
    func addSubComponent()
    func removeFromParent()
    var customName: String? { get set }
    var suggestedName: String? { get }
    var prefix: String? { get }
    var suffix: String? { get }
}

extension DomainComponent {
    static var canAddSubComponents: Bool { return false }
    var isRemovable: Bool { return false }
    func addSubComponent() {}
    func removeFromParent() {}
    
    var name: String {
        return customName ?? suggestedName ?? ""
    }
    var customName: String? { return nil }
    var suggestedName: String? { return nil }
    var prefix: String? { return nil }
    var suffix: String? { return nil }
}

class MainComponent {
    
}

class FinalComponent {
    var subComponents: [DomainComponent]? = nil
    var placeholderName: String = ""
}

protocol UseCaseSubComponent: DomainComponent {
    var parent: UseCaseComponent? { get set }
}

extension UseCaseSubComponent {
    var suggestedName: String? {
        guard let parentPrefix = parent?.prefix,
            let suffix = suffix else { return nil }
        return parentPrefix + suffix
    }
    
    var suffix: String? {
        return type(of: self).userDescription
    }
}

class UseCaseComponent: MainComponent, DomainComponent {
    static let userDescription: String = "UseCase"
    let presentation = PresentationComponent()
    var entity: EntityComponent = .init()
    var request: RequestComponent? = .init()
    var response: ResponseComponent?  = .init()
    var customName: String? {
        didSet {
            let defaultSuffix = UseCaseComponent.userDescription
            guard let customName = customName,
                customName.hasSuffix(defaultSuffix) == false else {
                return
            }
            self.customName = customName + defaultSuffix
        }
    }
    var subComponents: [DomainComponent]? {
        var comp: [DomainComponent] = [entity, presentation]
        if let request = request { comp.append(request) }
        if let response = response { comp.append(response) }
        return comp
    }
    
    override init() {
        super.init()
        subComponents?.forEach {($0 as? UseCaseSubComponent)?.parent = self }
    }
    
//    func addSubComponent() {
//        let entity = EntityComponent()
//        entity.parent = self
//        entities.append(entity)
//    }
    
    var prefix: String? {
        if name.isEmpty { return nil }
        return name.replacingOccurrences(of: UseCaseComponent.userDescription, with: "")
    }
}

class EntityComponent: MainComponent, UseCaseSubComponent, Equatable {
    static let userDescription: String = "Entity"
    static let canAddSubComponents = true
    weak var parent: UseCaseComponent?
    var gateways: [EntityGatewayComponent] = []
    var customName: String?
    var subComponents: [DomainComponent]? { return gateways }
    override init() {
        super.init()
        addSubComponent()
        addSubComponent()
    }
    
    func addSubComponent() {
        let gateway = EntityGatewayComponent()
        gateway.parent = self
        gateways.append(gateway)
    }
    
    static func == (lhs: EntityComponent, rhs: EntityComponent) -> Bool {
        return lhs === rhs
    }
    var suggestedName: String? = nil
    var suffix: String? = nil
    var prefix: String? = nil
}

class EntityGatewayComponent: MainComponent, DomainComponent, Equatable {
    static let userDescription: String = "EntityGateway"
    static let shortUserDescription: String = "Gateway"
    static let gatewayTypeSuggestionOrder = [EntityGatewayType.remote, .local, .unknown]
    static let canAddSubComponents = true
    weak var parent: EntityComponent?
    var stores: [EntityStoreComponent] = []
    var customName: String?
    var isRemovable: Bool {
        return (parent?.gateways.count ?? 0) > 1
    }
    var subComponents: [DomainComponent]? { return stores }
    var gatewayTypeSuggestion: EntityGatewayType {
        guard let index = indexInParent else { return .unknown }
        let suggestions = EntityGatewayComponent.gatewayTypeSuggestionOrder
        if index >= suggestions.count { return .unknown }
        return suggestions[index]
    }
    
    override init() {
        super.init()
        addSubComponent()
    }
    
    func addSubComponent() {
        let store = EntityStoreComponent()
        store.parent = self
        stores.append(store)
    }
    
    func removeFromParent() {
        guard let index = indexInParent else { return }
        parent?.gateways.remove(at: index)
    }
    
    private var indexInParent: Int? {
        return parent?.gateways.firstIndex(of: self)
    }
    static func == (lhs: EntityGatewayComponent, rhs: EntityGatewayComponent) -> Bool {
        return lhs === rhs
    }
    
    var prefix: String? {
        return parent?.name
    }
    
    var suffix: String? {
        return (gatewayTypeSuggestion.userDescription ?? "") + EntityGatewayComponent.shortUserDescription
    }
    
    var suggestedName: String? {
        guard let prefix = prefix, let suffix = suffix else { return nil }
        return prefix + suffix
    }
}

class EntityStoreComponent: FinalComponent, DomainComponent, Equatable {
    static let userDescription: String = "EntityStore"
    static let shortUserDescription: String = "Store"
    weak var parent: EntityGatewayComponent?
    var customName: String?
    var isRemovable: Bool {
        return (parent?.stores.count ?? 0) > 1
    }
    
    func removeFromParent() {
        guard let index = parent?.stores.firstIndex(of: self) else { return }
        parent?.stores.remove(at: index)
    }
    
    static func == (lhs: EntityStoreComponent, rhs: EntityStoreComponent) -> Bool {
        return lhs === rhs
    }
    
    var prefix: String? {
        return parent?.prefix
    }
    
    var suffix: String? {
        return (parent?.gatewayTypeSuggestion.userDescription ?? "") + EntityStoreComponent.shortUserDescription
    }
    
    var suggestedName: String? {
        guard let prefix = prefix, let suffix = suffix else { return nil }
        return prefix + suffix
    }
}

enum EntityGatewayType {
    case remote, local, unknown
    
    var userDescription: String? {
        if self == .unknown { return nil }
        return String(describing: self).capitalized
    }
}

class PresentationComponent: FinalComponent, UseCaseSubComponent {
    static let userDescription: String = "Presentation"
    weak var parent: UseCaseComponent?
    var customName: String?
}

class RequestComponent: FinalComponent, UseCaseSubComponent {
    static let userDescription: String = "Request"
    weak var parent: UseCaseComponent?
    var customName: String?
}

class ResponseComponent: FinalComponent, UseCaseSubComponent {
    static let userDescription: String = "Response"
    weak var parent: UseCaseComponent?
    var customName: String?
//    var suggestedName: String?
}
