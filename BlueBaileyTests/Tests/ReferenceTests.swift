//
//  ReferencesTests.swift
//  ReferencesTests
//
//  Created by Adrian-Dieter Bilescu on 6/14/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
@testable import BlueBailey

class ReferencesTests: XCTestCase {

    var rootReference = Reference()

    func testOnCreation_HasNoChildren() {
        XCTAssertEqual(rootReference.children.count, 0)
    }
    
    func testReferenceAddingOneChild_ShouldHaveOneChild() {
        try! addOneChildReference()
        XCTAssertEqual(rootReference.children.count, 1)
    }

    func testAddingChildReferenceWithSameName_ShouldThrowReferenceAlreadyExists() {
        try! addOneChildReference("John")
        assertThrowsErrorEqual(try addOneChildReference("John"), error: ReferenceError.referenceAlreadyExists)
    }
    
    func testNewReference_HasNoParent() {
        XCTAssertNil(rootReference.parent)
    }
    
    func testAddingChild_ChildShouldHaveParent() {
        let childReference = try! addOneChildReference()
        XCTAssertEqual(childReference.parent, rootReference)
    }
    
    func testOneChildReference_RemovingChildFromParent_ParentShouldHaveNoChildren() {
        let childReference = try! addOneChildReference()
        try! childReference.removeFromParent()
        XCTAssertEqual(rootReference.children.count, 0)
    }
    
    func testNoChildReference_RemovingFromParent_ParentShouldHaveNoChildren() {
        assertThrowsErrorEqual(try rootReference.removeFromParent(), error: ReferenceError.hasNoParent)
    }
    
    func testSameNameReferences_HavingDifferentChildren_AreNotEqual() {
        let referenceOne = Reference(name: "Anna")
        try! referenceOne.addChild("Ben")
        let referenceTwo = Reference(name: "Anna")
        
        XCTAssertNotEqual(referenceOne, referenceTwo)
    }
    
    func testSameNameReferences_HavingDifferentChildren_HaveEqualName() {
        let referenceOne = Reference(name: "Anna")
        try! referenceOne.addChild("Ben")
        let referenceTwo = Reference(name: "Anna")
        
        XCTAssert(referenceOne.hasEqualName(to: referenceTwo))
    }
    
    //MARK: - Debug Descriptiuon
    
    func testReferenceWithNoChildren_DebugDescriptionDisplaysNameOnly() {
        rootReference = Reference(name: "John")
        let expected = "Name: John;"
        let actual = rootReference.debugDescription
        
        XCTAssertEqual(expected, actual)
    }
    
    func testReferenceWithoutName_DebugDescriptionDisplaysNoneName() {
        rootReference = Reference(name: "")
        let expected = "Name: <none>;"
        let actual = rootReference.debugDescription
        
        XCTAssertEqual(expected, actual)
    }
    
    func testReferenceWithOneChild_DisplaysChildWithName() {
        rootReference = Reference(name: "John")
        try! rootReference.addChild("Ben")
        let expected = """
Name: John;
    - Name: Ben;
"""
        let actual = rootReference.debugDescription
        
        XCTAssertEqual(expected, actual)
    }
    
    
    func testReferenceWithManyChildren_DisplaysChildrenWithNameOneAfterAnother() {
        rootReference = Reference(name: "John")
        try! rootReference.addChild("Benjamin")
        try! rootReference.addChild("Bill")
        try! rootReference.addChild("Bob")
        let expected = """
Name: John;
    - Name: Benjamin;
    - Name: Bill;
    - Name: Bob;
"""
        let actual = rootReference.debugDescription
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testReferenceWithManyGenerationsChildren() {
        rootReference = Reference(name: "John")
        let ben = try! rootReference.addChild("Benjamin")
        let bill = try! ben.addChild("Bill")
        try! bill.addChild("Charlie")
        let expected = """
Name: John;
    - Name: Benjamin;
        - Name: Bill;
            - Name: Charlie;
"""
        let actual = rootReference.debugDescription
        
        XCTAssertEqual(expected, actual)
    }
    

    
    //MARK: - Private
    @discardableResult
    private func addOneChildReference(_ named: String = "") throws -> Reference {
        return try rootReference.addChild(named)
    }

}


extension XCTest {
    func assertThrowsErrorEqual<T, E: Equatable>(_ expression: @autoclosure () throws -> T, error: E?, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        XCTAssertThrowsError(try expression(), message(), file: file, line: line) { (actualError) in
            XCTAssertEqual(actualError as? E, error, file: file, line: line)
        }
    }
}


