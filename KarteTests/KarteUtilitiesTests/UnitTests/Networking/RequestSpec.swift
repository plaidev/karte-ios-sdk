//
//  Copyright 2024 PLAID, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import XCTest
@testable import KarteUtilities

class RequestSpec: XCTestCase {

    // MARK: - buildURLRequest

    func testBuildURLRequestWithPath() throws {
        let baseURL = URL(string: "https://example.com")!
        let request = RequestMock(baseURL: baseURL, path: "/test/path")

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.url?.absoluteString, "https://example.com/test/path", "should build URL with path")
    }

    func testBuildURLRequestWithEmptyPath() throws {
        let baseURL = URL(string: "https://example.com")!
        let request = RequestMock(baseURL: baseURL, path: "")

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.url?.absoluteString, "https://example.com", "should use baseURL directly when path is empty")
    }

    func testBuildURLRequestHTTPMethod() throws {
        let request = RequestMock(method: .post)

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.httpMethod, "POST", "should set HTTP method correctly")
    }

    func testBuildURLRequestAcceptHeader() throws {
        let request = RequestMock(acceptableMediaType: "application/test")

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "application/test", "should set Accept header from responseParser")
    }

    func testBuildURLRequestCustomHeaderFields() throws {
        let request = RequestMock(headerFields: ["X-Custom-Header": "CustomValue"])

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Custom-Header"), "CustomValue", "should set custom header fields")
    }

    func testBuildURLRequestContentType() throws {
        let request = RequestMock(contentType: "application/custom")

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/custom", "should set Content-Type header from bodyParameters")
    }

    func testBuildURLRequestHttpBody() throws {
        let testData = "test data".data(using: .utf8)!
        let request = RequestMock(buildBodyResult: testData)

        let urlRequest = try request.buildURLRequest()

        XCTAssertEqual(urlRequest.httpBody, testData, "should set httpBody from bodyParameters.build()")
    }

    func testBuildURLRequestPropagatesBuildBodyError() {
        let request = RequestMock(shouldThrowFromBuildBody: true)

        XCTAssertThrowsError(try request.buildURLRequest(), "should propagate errors from bodyParameters.build()")
    }

    // MARK: - parse

    func testParseWithSuccessStatusCode() throws {
        let testData = "test data".data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let request = RequestMock()

        let result = try request.parse(data: testData, urlResponse: response)

        XCTAssertEqual(result, "success response", "should return the expected response")
    }

    func testParsePropagatesParseError() {
        let testData = "test data".data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let request = RequestMock(shouldThrowFromParse: true)

        XCTAssertThrowsError(try request.parse(data: testData, urlResponse: response), "should propagate errors from dataParser.parse()")
    }

    func testParseWithFailureStatusCode() {
        let statusCode = 400
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        let request = RequestMock()

        XCTAssertThrowsError(try request.statusCodeCheck(urlResponse: response)) { error in
            guard case NetworkingError.invalidStatusCode(let code) = error else {
                XCTFail("Expected NetworkingError.invalidStatusCode, got \(error)")
                return
            }
            XCTAssertEqual(code, statusCode, "should throw invalidStatusCode with correct status code")
        }
    }

    // MARK: - default implementation

    func testDefaultHeaderFieldsIsEmpty() {
        let request = RequestMock()

        XCTAssertTrue(request.headerFields.isEmpty, "default headerFields should be empty dictionary")
    }

    func testDefaultStatusCodeCheckWithSuccessStatusCode() {
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let request = DefaultRequest()
        XCTAssertNoThrow(try request.statusCodeCheck(urlResponse: response), "should not throw for 200 status code")
    }

    func testDefaultStatusCodeCheckWithFailureStatusCode() {
        let statusCode = 400
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        let request = DefaultRequest()
        XCTAssertThrowsError(try request.statusCodeCheck(urlResponse: response)) { error in
            guard case NetworkingError.invalidStatusCode(let code) = error else {
                XCTFail("Expected NetworkingError.invalidStatusCode, got \(error)")
                return
            }
            XCTAssertEqual(code, statusCode, "should throw invalidStatusCode with correct status code")
        }
    }
}

private struct DefaultRequest: Request {
    typealias Response = String
    var baseURL: URL { URL(string: "https://example.com")! }
    var method: HTTPMethod { .get }
    var path: String { "" }
    var headerFields: [String: String] { [:] }
    var contentType: String { "" }
    func buildBody() throws -> Data? { nil }
    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> String { "" }
}
