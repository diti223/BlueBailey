//
//  Reference.swift
//  Nodes
//
//  Created by Adrian-Dieter Bilescu on 6/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

class Reference: Equatable {
    private (set) var children: [Reference] = []
    weak var parent: Reference?
    let name: String
    
    init(name: String = "") {
        self.name = name
    }
    
    func addChild(_ child: Reference) throws {
        guard !children.contains(child) else {
            throw ReferenceError.referenceAlreadyExists
        }
        self.children.append(child)
        child.parent = self
    }
    
    @discardableResult
    func addChild(_ name: String) throws -> Reference {
        let newChild = Reference(name: name)
        try addChild(newChild)
        return newChild
    }
    
    static func ==(lhs: Reference, rhs: Reference) -> Bool {
        if lhs.name != rhs.name { return false }
        if lhs.children != rhs.children { return false }
        return true
    }
    
    func hasEqualName(to node: Reference) -> Bool {
        return name == node.name
    }
    
    func removeFromParent() throws {
        guard let index = parent?.children.firstIndex(of: self) else {
            throw ReferenceError.hasNoParent
        }
        parent?.children.remove(at: index)
    }
    
    subscript(name: String) -> Reference? {
        return children.first(where: { $0.name == name })
    }
}

enum ReferenceError: Error {
    case referenceAlreadyExists
    case hasNoParent
}
