//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

public protocol ProjectGateway {
    func open(from url: URL) -> Project?
}
