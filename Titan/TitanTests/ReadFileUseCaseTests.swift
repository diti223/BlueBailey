//
//  ReadFileUseCaseTests.swift
//  Titan
//
//  Created by Adrian-Dieter Bilescu on 10/25/19.
//  Copyright © 2019 Bilescu. All rights reserved.
//

import XCTest
import TitanAPI

class ReadFileUseCaseTests: XCTestCase {
    var sut: ReadFileUseCase!

    override func setUp() {
        sut = ReadFileUseCase()
    }

    func test() {
        XCTAssertNoThrow(try {
            Bundle.testBundle.resourceURL!.appendingPathComponent("Projects.bundle/Empty")
            let file = File(path: URL(fileURLWithPath: ""))
            _ = try self.sut.read(file)

        }())
    }
}
