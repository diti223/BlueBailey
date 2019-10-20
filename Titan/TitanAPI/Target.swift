//
// Created by Adrian Bilescu on 20/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public struct Target: Hashable {
    public let name: String
    public let fileNames: [String]
}


public extension Collection where Iterator.Element == Target {
    subscript(name: String) -> Target? {
        get {
            return self.first(where: { $0.name == name })
        }
    }
}
