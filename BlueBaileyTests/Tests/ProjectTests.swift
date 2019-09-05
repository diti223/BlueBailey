//
//  ProjectTests.swift
//  NodesTests
//
//  Created by Adrian-Dieter Bilescu on 6/22/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
@testable import BlueBailey

class ProjectTests: XCTestCase {

    let billyProject = Project(url: URL(string: "/Users/adrian-dieterbilescu/Projects/Nodes/NodesTests/Billy/Billy.xcodeproj")!)!
    
    func testProjectInitWithName_HasSameName() {
        let expectedName = String.random
        let actualName = Project(name: expectedName).name
        
        XCTAssert(expectedName == actualName)
    }
    
    func testProjectInitWithName_HasNoRootNode() {
        let sut = Project(name: .random)
        XCTAssertNil(sut.root)
    }
    
    func testInitWithProjectURL_HasProjectNameEqualToXcodeProjFileName() {
        let sut = billyProject
        XCTAssertEqual(sut.name, "Billy")
    }
    
    func testInitWithAnyFileURL_ShouldReturnNoProject() {
        let sut = Project(url: URL(string: "/Users/adrian-dieterbilescu/Projects/Nodes/NodesTests/Billy/Billy/main.swift")!)
        XCTAssertNil(sut)
    }
    
    func testInitWithEmptyFileURL_ShouldReturnNoProject() {
        let sut = Project(url: URL(string: "/Users/adrian-dieterbilescu/Projects/Nodes/NodesTests/Billy/Billy/EmptyFile")!)
        XCTAssertNil(sut)
    }
    
    func testInitWithProjectURLFileThatDoesntExist_ShouldReturnNoProject() {
        let sut = Project(url: URL(string: "/Users/Projects/Some/Path/Project.xcodeproj")!)
        XCTAssertNil(sut)
    }
    
    func testInitWithBillyProjectURL_HasRootNode() {
        let sut = billyProject
        XCTAssertNotNil(sut.root)
    }
    
    
}
