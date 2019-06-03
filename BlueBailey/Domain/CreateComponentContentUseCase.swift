//
//  CreateComponentContentUseCase.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 5/31/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

// Note this is not a correct use of a use case
// It should communicate through a gateway with File & Project operations and create the files of the project
//
class CreateComponentContentUseCase: UseCase {
    enum FileError: Error {
        case noData
    }
    let request: CreateFileRequest
    weak var handler: CreateFilePresentation?
    
    init(request: CreateFileRequest, handler: CreateFilePresentation) {
        self.request = request
        self.handler = handler
    }
    
    func execute() {
        let component = request.component
        let templateFile = type(of: component).fileName
        guard let url = Bundle.main.url(forResource: templateFile, withExtension: "") else {
            handler?.templateNotFound()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard var string = String(data: data, encoding: .utf8) else {
                throw FileError.noData
            }
            string = component.keywords.reduce(string) { (currentText, keyword) -> String in
                return currentText.replacingOccurrences(of: "{\(keyword.key)}", with: keyword.value)
            }
            handler?.handleCompletedFile(named: component.name, content: string, path: type(of: component).groupPath)
        }
        catch {
            handler?.templateFileError(error: error)
        }
    }
    
}


extension Property {
    var declaration: String {
        return "\(memoryType.declaration) \(name): \(declarationType)"
    }
    
    var functionParameter: String {
        return "\(name): \(type)"
    }
    
    /// weak types will be declared as optionals
    var declarationType: String {
        switch memoryType {
        case .weak:
            return (type.hasSuffix("?") || type.hasSuffix("!")) ? type : "\(type)?"
        default:
            return type
        }
    }
}

extension Property.MemoryType {
    var declaration: String {
        switch self {
        case .weak:
            return "weak var"
        default:
            return String(describing: self)
        }
    }
    
}

extension Sequence where Element == Property {

    var functionParameters: String {
        return map { $0.functionParameter }.joined(separator: ", ")
    }
    
    var initialization: String {
        return """
init(\(functionParameters)) {
    \(map({ "self.\($0.name) = \($0.name)" }).joined(separator: "\n    "))
}
"""
    }
    
    var declaration: String {
        return map { $0.declaration }.joined(separator: "\n    ")
    }
}


