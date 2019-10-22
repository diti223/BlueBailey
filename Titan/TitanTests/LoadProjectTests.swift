//
// Created by Adrian Bilescu on 16/10/2019.
// Copyright (c) 2019 Bilescu. All rights reserved.
//

import TitanAPI
import XCTest

class ProjectGatewaySpy: ProjectGateway {
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
        let (sut, projectGatewaySpy) = makeSUT(url: url)
        
        _ = try? sut.load()
        
        XCTAssertEqual(url, projectGatewaySpy.requestedURL)
    }

    func testLoadProject_InvokesOpenURLOnce() {
        let (sut, projectGatewaySpy) = makeSUT()

        _ = try? sut.load()

        XCTAssertEqual(1, projectGatewaySpy.invokedOpenCount)
    }

    func testLoadProjectAtInavlidURL_ThrowsError() {
        let (sut, _) = makeSUT()

        XCTAssertThrowsError(try sut.load())
    }

    private func makeSUT(url: URL = URL(string: "www.any-url.com")!) -> (ProjectLoader, ProjectGatewaySpy) {
        let spy = ProjectGatewaySpy()
        sut = .init(url: url, projectGateway: spy)
        return (sut, spy)
    }
}
