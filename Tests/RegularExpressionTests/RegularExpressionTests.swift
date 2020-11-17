import XCTest
@testable import RegularExpression

final class RegularExpressionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RegularExpression().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
