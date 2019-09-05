//
//  ReferencePathTests.swift
//  NodesTests
//
//  Created by Adrian-Dieter Bilescu on 6/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
@testable import BlueBailey

class ReferencePathTests: XCTestCase {

    let root = Reference()

    func testSubscriptNode_ReturnChildWithName() {
        let children = try! addChildren("A", "B", "C")
        
        let expectedNode = children[1]
        let actualNode = root["B"]
        XCTAssertEqual(expectedNode, actualNode)
    }
    
    func testSubscriptNode_ChildDoesntExist() {
        try! addChildren("A", "B", "C")
        XCTAssertNil(root["D"])
    }
    
    
    @discardableResult
    private func addChildren(_ names: String...) throws -> [Reference] {
        return try names.map { try root.addChild($0) }
    }

}

