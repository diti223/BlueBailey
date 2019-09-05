//
//  ProjectStoreTestd.swift
//  NodesTests
//
//  Created by Adrian-Dieter Bilescu on 6/24/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
@testable import BlueBailey

class ProjectStoreTests: XCTestCase {

    func testFetchExistingProject_ProjectExists() {
        let sut = ProjectStore()
        XCTAssertNotNil(sut.fetchProject(at: URL(string: "/Users/adrian-dieterbilescu/Projects/Nodes/NodesTests/Billy/Billy.xcodeproj")!))
    }
}
