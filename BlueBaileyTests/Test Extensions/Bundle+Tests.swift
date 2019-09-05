//
//  Bundle+Tests.swift
//  CorePaymentTests
//
//  Created by Adrian Bilescu on 27/02/2019.
//  Copyright © 2019 Endava. All rights reserved.
//

import XCTest

extension XCTestCase {
    var testBundle: Bundle {
        return Bundle.test(type: type(of: self))
    }
}

extension Bundle {
    static func test(type: XCTestCase.Type) -> Bundle {
        return Bundle(for: type)
    }
}
