//
// Created by Adrian Bilescu on 21/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public struct File: Equatable, Hashable {
    let name: String
    let path: String

    public init(path: URL) {
        self.path = path.path
        self.name = path.lastPathComponent
    }
}

public extension Collection where Iterator.Element == File {
    subscript(name: String) -> File? {
        get {
            return first(where: { $0.name == name })
        }
    }
}