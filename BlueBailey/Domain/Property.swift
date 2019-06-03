//
//  Property.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 6/1/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

struct Property {
    enum MemoryType {
        case weak, `var`, `let`
    }
    let memoryType: MemoryType
    let name: String
    let type: String
    
    init(name: String, type: String, memoryType: MemoryType = .let) {
        self.memoryType = memoryType
        self.name = name
        self.type = type
    }
}
