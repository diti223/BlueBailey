//
// Created by Adrian Bilescu on 20/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public struct Target: Hashable {
    public let name: String
    let files: [File]

    public var fileNames: [String] {
        return files.map { $0.name }
    }

    public init(name: String, files: [File]) {
        self.name = name
        self.files = files
    }

    func contains(file: File) -> Bool {
        return files.contains(where: { $0.path == file.path })
    }
}

public extension Collection where Iterator.Element == Target {
    subscript(name: String) -> Target? {
        get {
            return self.first(where: { $0.name == name })
        }
    }
}