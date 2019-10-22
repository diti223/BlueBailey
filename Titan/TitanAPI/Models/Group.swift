//
// Created by Adrian Bilescu on 20/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public struct Group: Equatable {
    public let name: String
    public let files: [File]
    public let groups: [Group]

    public var fileNames: [String] {
        return files.map { $0.name }
    }

    public init(name: String, files: [File], groups: [Group] = []) {
        self.name = name
        self.files = files
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
