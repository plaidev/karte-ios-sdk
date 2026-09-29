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

class FetchNativeSDKConfigEventSpec: XCTestCase {

    func testFetchNativeSDKConfigEvent() throws {
        let event = Event(.fetchNativeSDKConfig(flags: ["feature_a": true, "feature_b": false]))

        XCTAssertEqual(event.eventName, .fetchNativeSDKConfig, "eventName is fetchNativeSDKConfig")
        XCTAssertEqual(event.values.count, 1, "values count")
        XCTAssertTrue(try XCTUnwrap(event.values.bool(forKeyPath: "flags.feature_a")), "flags.feature_a")
        XCTAssertFalse(try XCTUnwrap(event.values.bool(forKeyPath: "flags.feature_b")), "flags.feature_b")
        XCTAssertTrue(event.isRetryable, "isRetryable is true")
    }
}
