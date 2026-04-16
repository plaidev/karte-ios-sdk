import XCTest
@testable import KarteUtilities

class HTTPMethodSpec: XCTestCase {

    func testRawValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET", "GET raw value")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST", "POST raw value")
    }

    func testInitializationFromRawValue() {
        XCTAssertEqual(HTTPMethod(rawValue: "GET"), .get, "creates GET from string")
        XCTAssertEqual(HTTPMethod(rawValue: "POST"), .post, "creates POST from string")
        XCTAssertNil(HTTPMethod(rawValue: "INVALID"), "returns nil for invalid string")
        XCTAssertNil(HTTPMethod(rawValue: "get"), "is case sensitive")
    }
}
