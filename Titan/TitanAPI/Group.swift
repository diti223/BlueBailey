//
// Created by Adrian Bilescu on 20/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public struct Group: Equatable {
    public let name: String
    public let fileNames: [String]
    public let groups: [Group]

    public init(name: String, fileNames: [String], groups: [Group] = []) {
        self.name = name
        self.fileNames = fileNames
        self.groups = groups
    }
}

public extension Collection where Iterator.Element == Group {
    subscript(name: String) -> Group? {
        get {
            return first(where: { $0.name == name })
        }
    }
}
