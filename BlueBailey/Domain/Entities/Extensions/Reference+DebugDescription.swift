//
//  Node+DebugDescription.swift
//  Nodes
//
//  Created by Adrian-Dieter Bilescu on 6/17/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

extension Reference: CustomDebugStringConvertible {
    var debugDescription: String {
        let childrenDescription = children.map { "\($0.debugDescription)" }
            .joined(separator: "\n")
        let desc = simpleDescription(indentTabsCount: parentsCount)
        if childrenDescription.isEmpty {
            return desc
        }
        
        return """
        \(desc)
        \(childrenDescription)
        """
    }
    
    private func simpleDescription(indentTabsCount: Int = 0) -> String {
        if indentTabsCount == 0 {
            return "Name: \(name.isEmpty ? "<none>": name);"
        }
        let indention = (0..<indentTabsCount).map { _ in "    " }.joined(separator: "")
        return "\(indention)- \(simpleDescription())"
    }
    
    private var parentsCount: Int {
        var parent = self.parent
        var parentCount = 0
        while parent != nil {
            parentCount += 1
            parent = parent?.parent
        }
        return parentCount
    }
}
