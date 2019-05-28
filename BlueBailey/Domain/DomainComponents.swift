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
    let entity = EntityComponent()
    let presentation = PresentationComponent()
    var request: RequestComponent?
    var response: ResponseComponent?
    
    
    override init() {
        super.init()
        let request = RequestComponent()
        let response = ResponseComponent()
        self.request = request
        self.response = response
        self.subComponents = [entity, presentation, request, response]
    }
}


class EntityComponent: MainComponent, DomainComponent {
    static let userDescription: String = "Entity"
    
    override init() {
        super.init()
        self.subComponents = [EntityGatewayComponent()]
    }
    
}

class EntityGatewayComponent: FinalComponent, DomainComponent {
    static let userDescription: String = "EntityGateway"
    static let prefixSuggestionOrder = [EntityGatewayType.remote, .local, .unknown]
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