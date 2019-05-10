import XCTest
@testable import BlueBailey

final class BlueBaileyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BlueBailey().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
