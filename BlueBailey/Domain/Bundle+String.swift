//
//  Bundle+String.swift
//  BlueBailey
//
//  Created by Adrian-Dieter Bilescu on 6/1/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import Foundation

extension Bundle {
    func content(forResource resource: String?, extension: String?) throws -> String? {
        guard let url = url(forResource: resource, withExtension: `extension`) else { return nil }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
