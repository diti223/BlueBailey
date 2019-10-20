//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import TitanAPI
import XCTest

class ProjectManagerSpy: ProjectManager {
    var requestedURL: URL?
    var invokedOpenCount = 0

    func open(from url: URL) -> Project? {
        invokedOpenCount += 1
        requestedURL = url
        return nil
    }
}

class LoadProjectFromXCodeTests: XCTestCase {
    private var sut: ProjectLoader!

    func testLoadProject_InvokesOpenWithURL() {
        let url = URL(string: "https://some-url.com")!
        let (sut, projectManagerSpy) = makeSUT(url: url)
        
        _ = try? sut.load()
        
        XCTAssertEqual(url, projectManagerSpy.requestedURL)
    }

    func testLoadProject_InvokesOpenURLOnce() {
        let (sut, projectManagerSpy) = makeSUT()

        _ = try? sut.load()

        XCTAssertEqual(1, projectManagerSpy.invokedOpenCount)
    }

    func testLoadProjectAtInavlidURL_ThrowsError() {
        let (sut, _) = makeSUT()

        XCTAssertThrowsError(try sut.load())
    }

    private func makeSUT(url: URL = URL(string: "www.any-url.com")!) -> (ProjectLoader, ProjectManagerSpy) {
        let projectManagerSpy = ProjectManagerSpy()
        sut = .init(url: url, projectManager: projectManagerSpy)
        return (sut, projectManagerSpy)
    }
}
