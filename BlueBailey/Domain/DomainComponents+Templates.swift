//
//  DomainComponents+Templates.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/31/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

extension DomainComponent {
    static var fileName: String { return "\(userDescription)Template" }
    var propertyName: String {
        return name.firstLetterLowercased
    }
}
extension UseCaseComponent: DomainTemplates {
    static let groupPath: String = "Domain/UseCases"
    var keywords: [String : String] {
        let properties = Property.properties(from: self)
        return ["UseCaseName": name,
                "Declarations": properties.declaration,
                "PropertyInitialization": properties.initialization]
    }
}

extension Property {
    static func properties(from useCase: UseCaseComponent) -> [Property] {
        var properties: [Property] = []
        let gatewayProperties = useCase.entity.gateways.map { Property(name: $0.propertyName, type: $0.name) }
        properties.append(contentsOf: gatewayProperties)
        
        let presentationProperty = Property(name: "handler", type: useCase.presentation.name, memoryType: .weak)
        properties.append(presentationProperty)
        
        if let request = useCase.request {
            let requestProperty = Property(name: "request", type: request.name)
            properties.append(requestProperty)
        }
        return properties
    }
}

extension PresentationComponent: DomainTemplates {
    static let groupPath: String = "Domain/Presentation"
    var keywords: [String : String] {
        return ["PresentationName": name]
    }
}

extension RequestComponent: DomainTemplates {
    static let groupPath: String = "Domain/IO/Request"
    var keywords: [String : String] {
        return ["RequestName": name]
    }
    
}
extension ResponseComponent: DomainTemplates {
    static let groupPath: String = "Domain/IO/Response"
    var keywords: [String : String] {
        return ["ResponseName": name]
    }
    
}
extension EntityComponent: DomainTemplates {
    static let groupPath: String = "Domain/Entities"
    var keywords: [String : String] {
        return ["Entity": name]
    }
    
}
extension EntityGatewayComponent: DomainTemplates {
    static let groupPath: String = "Domain/Gateways"
    var keywords: [String : String] {
        return ["EntityStoreGateway": name]
    }
    
}
extension EntityStoreComponent: DomainTemplates {
    static let groupPath: String = "Domain/Stores"
    var keywords: [String : String] {
        guard let gatewayName = parent?.name else { return [:] }
        return ["EntityStoreName": name,
                "EntityStoreGateway": gatewayName]
    }
    
}

struct UseCaseFactoryTemplate: DomainTemplates {
    static let groupPath: String = "Presentation"
    static let fileName = "UseCaseFactoryTemplate"
    static let name = "UseCaseFactory"
    let useCases: [UseCaseComponent]
    private var allGateways: [EntityGatewayComponent] {
        return useCases.flatMap { $0.entity.gateways }
    }
    private var properties: [Property] {
        return allGateways.map { Property(entityGateway: $0) }
    }
    
    init(useCases: [UseCaseComponent]) {
        self.useCases = useCases
    }
    
    func factoryMethod(for useCase: UseCaseComponent) -> String {
        let factoryMethodParameters = useCaseMethodParameters(for: useCase)
        let useCaseInitialization = Property.properties(from: useCase).map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        return """
func \(useCase.name.firstLetterLowercased)(\(factoryMethodParameters)) {
        return \(useCase.name)(\(useCaseInitialization))
    }
"""
    }
    
    private func useCaseMethodParameters(for useCase: UseCaseComponent) -> String {
        var properties: [Property] = []
        if let request = useCase.request {
            properties.append(Property(name: request.name, type: request.propertyName))
        }
        let presentation = useCase.presentation
        properties.append(Property(name: presentation.name, type: presentation.propertyName))
        return properties.functionParameters
    }
    
    var keywords: [String : String] {
        let properties = self.properties
        return ["UseCaseFactoryName": UseCaseFactoryTemplate.name,
                "Declarations": properties.declaration,
                "Initialization": properties.initialization,
                "UseCaseFactoryMethods": ""
        ]
    }
}

extension Property {
    init(entityGateway: EntityGatewayComponent) {
        self.init(name: entityGateway.name, type: entityGateway.propertyName)
    }
}

struct UseCaseDeclarationTemplate: DomainTemplates {
    static let groupPath: String = "Domain/UseCases"
    static let fileName = "UseCaseDeclarationTemplate"
    static let name: String = "UseCase"
    var keywords: [String : String] = [:]
}




extension DomainComponent {
    static var name: String { return userDescription }
}
