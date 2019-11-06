//
// Created by Adrian-Dieter Bilescu on 10/25/19.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import Foundation

protocol FileReader {
    func readFile(at path: URL) throws -> Data
}