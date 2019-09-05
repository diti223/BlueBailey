//
//  Project.swift
//  Nodes
//
//  Created by Adrian-Dieter Bilescu on 6/17/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

struct Project {
    let name: String
    var root: Reference?
    
    init(name: String) {
        self.name = name
    }
    
    private static let supportedExtension = "xcodeproj"
    
    init?(url: URL) {
        guard let name = Project.projectName(from: url) else {
            return nil
        }
        self.init(name: name)
        self.root = .init()
        
    }
    
    private static func projectName(from url: URL) -> String? {
        let lastPathComponent = url.lastPathComponent
        let fileExtension = Project.supportedExtension
        guard Project.fileManager.fileExists(atPath: url.path),
            lastPathComponent.hasSuffix(fileExtension) else {
                return nil
        }
        return lastPathComponent.replacingOccurrences(of: ".\(fileExtension)", with: "")
    }
    
    static let fileManager = FileManager.default
}
