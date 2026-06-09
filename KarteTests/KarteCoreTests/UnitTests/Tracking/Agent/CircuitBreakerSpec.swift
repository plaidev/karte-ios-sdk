//
//  Copyright 2021 PLAID, Inc.
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

class CircuitBreakerSpec: XCTestCase {

    private var todaySupplier: TodaySupplierMock!
    private var circuitBreaker: CircuitBreaker!

    override func setUp() {
        super.setUp()
        todaySupplier = TodaySupplierMock(DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 0))
        circuitBreaker = CircuitBreaker(threshold: 3, recoverAfterSec: 20, todaySupplier: todaySupplier)
    }

    func testThresholdBehavior() {
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true initially")
        circuitBreaker.countFailure()
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after 1 failure")
        circuitBreaker.countFailure()
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after 2 failures")
        circuitBreaker.countFailure()
        XCTAssertFalse(circuitBreaker.canRequest, "canRequest should be false after 3 failures")
    }

    func testResettingRemovesRestriction() {
        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        XCTAssertFalse(circuitBreaker.canRequest, "canRequest should be false after 3 failures")

        circuitBreaker.reset()
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after reset")

        circuitBreaker.countFailure()
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after 1 failure post-reset")
        circuitBreaker.countFailure()
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after 2 failures post-reset")
        circuitBreaker.countFailure()
        XCTAssertFalse(circuitBreaker.canRequest, "canRequest should be false after 3 failures post-reset")
    }

    func testAutoRecoveryAfterCertainPeriod() {
        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        XCTAssertFalse(circuitBreaker.canRequest, "canRequest should be false after 3 failures")

        todaySupplier.todayDateComponents = DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 21)
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after 21 seconds")

        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        circuitBreaker.countFailure()
        XCTAssertFalse(circuitBreaker.canRequest, "canRequest should be false after 3 failures in second cycle")

        todaySupplier.todayDateComponents = DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 42)
        XCTAssertTrue(circuitBreaker.canRequest, "canRequest should be true after another 21 seconds")
    }
}
