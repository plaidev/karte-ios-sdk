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
import KarteUtilities
@testable import KarteCore

class NativeSDKConfigFetcherTests: XCTestCase {
    private static let baseURL = URL(string: "https://cdn.example.com")!

    override func tearDown() {
        HTTPStubProtocol.removeAllStubs()
        super.tearDown()
    }

    func testFetchReturnsFlagsOnSuccess() async throws {
        HTTPStubProtocol.addStub(matcher: uri("/v0/native/sdk-config")) { _ in
            let responseData = #"{"feature_a": true, "feature_b": false}"#.data(using: .utf8)!
            return HTTPStubProtocol.StubResponse(
                statusCode: 200,
                headers: ["Content-Type": "application/json"],
                data: responseData
            )
        }
        let fetcher = DefaultNativeSDKConfigFetcher(sleep: { _ in assertionFailure("sleep should not be called") })
        let result = await fetcher.fetch(NativeSDKConfigRequest(baseURL: Self.baseURL, appKey: APP_KEY))
        guard case .success(let response) = result else {
            return XCTFail("Expected success but got \(result)")
        }
        XCTAssertTrue(try XCTUnwrap(response.flags["feature_a"]))
        XCTAssertFalse(try XCTUnwrap(response.flags["feature_b"]))
        XCTAssertEqual(response.ttl, 300)
    }

    func testFetchRetriesOnServerErrorAndSucceeds() async throws {
        var attemptCount = 0
        HTTPStubProtocol.addStub(matcher: uri("/v0/native/sdk-config")) { _ in
            attemptCount += 1
            if attemptCount < 3 {
                return HTTPStubProtocol.StubResponse(statusCode: 500, headers: [:], data: Data())
            }
            let responseData = #"{"feature_a": true}"#.data(using: .utf8)!
            return HTTPStubProtocol.StubResponse(
                statusCode: 200,
                headers: ["Content-Type": "application/json"],
                data: responseData
            )
        }
        let result = await DefaultNativeSDKConfigFetcher(sleep: { _ in })
            .fetch(NativeSDKConfigRequest(baseURL: Self.baseURL, appKey: APP_KEY))
        XCTAssertEqual(attemptCount, 3)
        guard case .success(let response) = result else {
            return XCTFail("Expected success but got \(result)")
        }
        XCTAssertTrue(try XCTUnwrap(response.flags["feature_a"]))
        XCTAssertEqual(response.ttl, 300)
    }

    func testFetchDoesNotRetryOnClientError() async {
        var attemptCount = 0
        HTTPStubProtocol.addStub(matcher: uri("/v0/native/sdk-config")) { _ in
            attemptCount += 1
            return HTTPStubProtocol.StubResponse(statusCode: 400, headers: [:], data: Data())
        }
        let result = await DefaultNativeSDKConfigFetcher(sleep: { _ in assertionFailure("sleep should not be called") })
            .fetch(NativeSDKConfigRequest(baseURL: Self.baseURL, appKey: APP_KEY))
        XCTAssertEqual(attemptCount, 1)
        guard case .failure(let message) = result else {
            return XCTFail("Expected failure but got \(result)")
        }
        XCTAssertEqual(message, "NativeSDKConfig fetch failed: HTTP 400")
    }

    func testFetchReturnsFailureAfterExhaustedRetries() async {
        var attemptCount = 0
        HTTPStubProtocol.addStub(matcher: uri("/v0/native/sdk-config")) { _ in
            attemptCount += 1
            return HTTPStubProtocol.StubResponse(statusCode: 500, headers: [:], data: Data())
        }
        let result = await DefaultNativeSDKConfigFetcher(sleep: { _ in })
            .fetch(NativeSDKConfigRequest(baseURL: Self.baseURL, appKey: APP_KEY))
        XCTAssertEqual(attemptCount, 3)
        guard case .failure(let message) = result else {
            return XCTFail("Expected failure but got \(result)")
        }
        XCTAssertEqual(message, "invalidStatusCode(500)")
    }
}
