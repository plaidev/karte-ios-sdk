//
//  Copyright 2026 PLAID, Inc.
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
@testable import KarteCore

class NativeSDKConfigRequestTests: XCTestCase {
    private let baseURL = URL(string: "https://cdn.example.com")!
    private let appKey = "test_app_key"

    private func dummyResponse() -> HTTPURLResponse {
        HTTPURLResponse(
            url: baseURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    func testBuildURLRequest() throws {
        let urlRequest = try NativeSDKConfigRequest(baseURL: baseURL, appKey: appKey).buildURLRequest()
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.path, "/v0/native/sdk-config")
        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        let appKeyItem = try XCTUnwrap(components?.queryItems?.first(where: { $0.name == "app_key" }))
        XCTAssertEqual(appKeyItem.value, appKey)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-KARTE-App-Key"), appKey)
    }

    func testParseExtractsBooleanFlags() throws {
        let data = #"{"flagA": true, "flagB": false}"#.data(using: .utf8)!
        let result = try NativeSDKConfigRequest(baseURL: baseURL, appKey: appKey).parse(data: data, urlResponse: dummyResponse())
        XCTAssertEqual(result.flags.count, 2)
        XCTAssertTrue(try XCTUnwrap(result.flags["flagA"]))
        XCTAssertFalse(try XCTUnwrap(result.flags["flagB"]))
    }

    func testParseIgnoresNonBooleanValues() throws {
        let data = #"{"boolKey": true, "stringKey": "hello", "numKey": 42, "nullKey": null}"#.data(using: .utf8)!
        let result = try NativeSDKConfigRequest(baseURL: baseURL, appKey: appKey).parse(data: data, urlResponse: dummyResponse())
        XCTAssertEqual(result.flags.count, 1)
        XCTAssertTrue(try XCTUnwrap(result.flags["boolKey"]))
    }

    func testCacheControlMaxAge() {
        let cases: [(headerFields: [String: String]?, expectedTTL: TimeInterval)] = [
            (["Cache-Control": "public s-maxage=3600, max-age=1800"], 1800),
            (["Cache-Control": "max-age=1800"], 1800),
            (["Cache-Control": "max-age=1"], 60), // 最小値の60に切り上げられる。
            (["Cache-Control": "max-age=9999"], 3600), // 最大値の3600に切り詰められる。
            (nil, 300), // デフォルト値にフォールバック
            ([:], 300), // デフォルト値にフォールバック
            (["Cache-Control": "  max-age=1800  "], 1800), // 前後の空白は許容される。
            (["Cache-Control": "max-age = 1800"], 300), // max-ageと=の間の空白は許容しない。デフォルト値にフォールバック
            (["Cache-Control": "s-maxage=3600"], 300), // デフォルト値にフォールバック
            (["Cache-Control": "max-age=abc"], 300), // デフォルト値にフォールバック
        ]
        for (headerFields, expectedTTL) in cases {
            let urlResponse = HTTPURLResponse(
                url: baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: headerFields
            )!
            XCTAssertEqual(urlResponse.cacheControlMaxAge(), expectedTTL)
        }
    }
}
