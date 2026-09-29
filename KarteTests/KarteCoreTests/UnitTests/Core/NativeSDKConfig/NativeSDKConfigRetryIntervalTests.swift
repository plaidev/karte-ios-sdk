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

class NativeSDKConfigRetryIntervalTests: XCTestCase {
    func testNanoseconds() {
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 1, randomFactor: 0.5), 250_000_000)
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 1, randomFactor: 1.0), 500_000_000)
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 1, randomFactor: 1.5), 750_000_000)
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 2, randomFactor: 0.5), 1_000_000_000)
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 2, randomFactor: 1.0), 2_000_000_000)
        XCTAssertEqual(NativeSDKConfigRetryInterval.nanoseconds(forAttempt: 2, randomFactor: 1.5), 3_000_000_000)
    }
}
