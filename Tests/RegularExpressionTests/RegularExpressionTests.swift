import XCTest
@testable import RegularExpression

final class RegularExpressionTests: XCTestCase {

	func testFound() throws {
		let foo = "foo"
		let regex = try RegularExpression(pattern: foo)
		let result = regex.rangeOfFirstMatch(in: foo)
		XCTAssertEqual(result, foo.startIndex..<foo.endIndex)
	}

	func testNotFound() throws {
		let foo = "foo"
		let regex = try RegularExpression(pattern: "bar")
		let result = regex.rangeOfFirstMatch(in: foo)
		XCTAssertNil(result)
	}

	func testPatternMatching() throws {
		let regex: RegularExpression = "(?i)Fo{2}"

		switch "foo" {
			case regex: break // Success
			default: XCTFail()
		}
	}

	func testMatching() throws {
		let regex: RegularExpression = "(?i)Fo{2}"

		let match = regex.firstMatch(in: "foo")!

		XCTAssertEqual(match.rangeCount, 1)
		XCTAssertEqual(match.range, "foo".startIndex..<"foo".endIndex)
	}

	func testMatchArray() throws {
		let regex: RegularExpression = "o"

		let matches = regex.matches(in: "foo")
		XCTAssertEqual(matches.count, 2)

		let firstO = "foo".index("foo".startIndex, offsetBy: 1)
		let secondO = "foo".index(after: firstO)

		XCTAssertEqual(matches[0].range, firstO..<secondO)
		XCTAssertEqual(matches[1].range, secondO..<"foo".endIndex)
	}

	func testCaptureGroups() throws {
		let regex: RegularExpression = "f(o+)b(a)r"

		let string = "foobar"

		let match = regex.firstMatch(in: string)!

		XCTAssertEqual(match[0], "foobar")
		XCTAssertEqual(match[1], "oo")
		XCTAssertEqual(match[2], "a")
	}

	func testNamedCaptureGroups() throws {
		let regex: RegularExpression = #"(?<first>\w+) (?<last>\w+)"#

		let string = "John Appleseed"

		let match = regex.firstMatch(in: string)!

		XCTAssertEqual(match[0], "John Appleseed")
		XCTAssertEqual(match["first"], "John")
		XCTAssertEqual(match["last"], "Appleseed")
	}

	func testReplacement() throws {
		let regex: RegularExpression = "oo"
		let string = "foobar"

		XCTAssertEqual(regex.replacingMatches(in: string, withTemplate: "aa"), "faabar")

		var string2 = "foobar"
		regex.replaceMatches(in: &string2, withTemplate: "aa")
		XCTAssertEqual(string2, "faabar")
	}

}

extension RegularExpressionTests {

	func testBlockPerf() {
		let string = "foobarbazquux"
		let regex: RegularExpression = "[^aeiou][aeiou]+"

		measure {
			for _ in 0..<50000 {
				regex.enumerateMatches(in: string) { (match, flags, stop) in
					// nothing
				}
			}
		}
	}

	func testAllMatchesPerf() {
		let string = "foobarbazquux"
		let regex: RegularExpression = "[^aeiou][aeiou]+"

		measure {
			for _ in 0..<50000 {
				_ = regex.matches(in: string)
			}
		}
	}

}
