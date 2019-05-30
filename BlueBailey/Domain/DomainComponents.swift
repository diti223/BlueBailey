//
//  DomainComponents.swift
//  BlueBailey
//
//  Created by Adrian Bilescu on 28/05/2019.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

protocol DomainComponent {
    static var userDescription: String { get }
    var fileName: String { get set }
    var subComponents: [DomainComponent]? { get }
    static var canAddSubComponents: Bool { get }
    var isRemovable: Bool { get }
}

extension DomainComponent {
    static var canAddSubComponents: Bool { return false }
    var isRemovable: Bool { return false }
}


class BaseComponent {
    var fileName: String = ""
}

class MainComponent: BaseComponent {
    var subComponents: [DomainComponent]? = []
}

class FinalComponent: BaseComponent {
    var subComponents: [DomainComponent]? = nil
    var placeholderName: String = ""
}


class UseCaseComponent: MainComponent, DomainComponent {
    static let userDescription: String = "UseCase"
    var entities: [EntityComponent] = []
    let presentation = PresentationComponent()
    var request: RequestComponent?
    var response: ResponseComponent?
    
    
    override init() {
        super.init()
        let entity = EntityComponent()
        entity.parent = self
        let request = RequestComponent()
        let response = ResponseComponent()
        self.request = request
        self.response = response
        self.subComponents = [entity, presentation, request, response]
    }
}


class EntityComponent: MainComponent, DomainComponent {
    static let userDescription: String = "Entity"
    var gateways: [EntityGatewayComponent] = []
    weak var parent: UseCaseComponent?
    
    override var subComponents: [DomainComponent]? {
        get {
            return gateways
        }
        set {
            self.gateways = newValue as? [EntityGatewayComponent] ?? []
        }
    }
    
    static let canAddSubComponents = true
    var isRemovable: Bool {
        return (parent?.entities.count ?? 0) > 1
    }
    
    override init() {
        super.init()
        self.subComponents = [EntityGatewayComponent()]
    }
    
}

class EntityGatewayComponent: MainComponent, DomainComponent {
    static let userDescription: String = "EntityGateway"
    static let prefixSuggestionOrder = [EntityGatewayType.remote, .local, .unknown]
    
    override init() {
        super.init()
        self.subComponents = [EntityStoreComponent()]
    }
}

class EntityStoreComponent: FinalComponent, DomainComponent {
    static let userDescription: String = "EntityStore"
}

enum EntityGatewayType {
    case remote, local, unknown
    
    var userDescription: String {
        if self == .unknown { return "" }
        return String(describing: self).capitalized
    }
}

class PresentationComponent: FinalComponent, DomainComponent {
    static let userDescription: String = "Presentation"
}

class RequestComponent: FinalComponent, DomainComponent {
    static let userDescription: String = "Request"
}

class ResponseComponent: FinalComponent, DomainComponent {
    static let userDescription: String = "Response"
}
