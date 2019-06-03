//
//  CreateFileUseCaseTests.swift
//  BlueBaileyTests
//
//  Created by Adrian-Dieter Bilescu on 6/1/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
@testable import BlueBailey

class CreateFileUseCaseTests: XCTestCase {
    var useCase: CreateComponentContentUseCase!
    
    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let component = DomainComponentMock()
        createUseCase(with: .init(component: component))
    }

    func createUseCase(with request: CreateFileRequest) {
        useCase = .init(request: request, handler: CreateFilePresentationDummy())
    }
}

extension XCTestCase {
    func assertFileContent(_ file1: String, _ file2: String, file: StaticString, line: UInt) {
        let string1 = try? testBundle.content(forResource: file1, extension: nil)
        let string2 = try? testBundle.content(forResource: file2, extension: nil)
        XCTAssert(string1 == string2, file: file, line: line)
    }
}

class CreateFilePresentationDummy: CreateFilePresentation {
    func templateNotFound() {}
    func templateFileError(error: Error) {}
}

class DomainComponentMock: DomainComponent {
    static let userDescription: String = "DomainMock"
    var subComponents: [DomainComponent]? = nil
    var customName: String? = .random()
    
}
