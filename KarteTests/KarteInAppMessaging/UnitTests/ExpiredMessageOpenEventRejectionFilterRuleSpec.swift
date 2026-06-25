//
//  Copyright 2023 PLAID, Inc.
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
@testable import KarteCore
@testable import KarteInAppMessaging

class ExpiredMessageOpenEventRejectionFilterRuleSpec: XCTestCase {
    private let stubDate = Date(timeIntervalSince1970: 1700000000)
    private lazy var rule = ExpiredMessageOpenEventRejectionFilterRule(interval: -180) { [self] in
        return stubDate
    }

    func testRejectWhenResponseTimestampExceedsInterval() {
        let event = Event(.message(type: .open, campaignId: "cid", shortenId: "sid", values: [
            "message": [
                "response_timestamp": iso8601DateTimeFormatter.string(from: stubDate.addingTimeInterval(-181))
            ]
        ]))
        XCTAssertTrue(rule.reject(event: event), "should reject when response timestamp exceeds interval")
    }

    func testNotRejectWhenResponseTimestampWithinInterval() {
        let event = Event(.message(type: .open, campaignId: "cid", shortenId: "sid", values: [
            "message": [
                "response_timestamp": iso8601DateTimeFormatter.string(from: stubDate.addingTimeInterval(-180))
            ]
        ]))
        XCTAssertFalse(rule.reject(event: event), "should not reject when response timestamp is within interval")
    }
}
