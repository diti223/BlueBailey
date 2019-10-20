//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation
public struct Project {
    public let name: String
    public let targets: Set<Target>
    public let groups: [Group]
}
