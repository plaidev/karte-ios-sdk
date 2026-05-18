//
//  Copyright 2020 PLAID, Inc.
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

class RenewVisitorIdEventSpec: XCTestCase {

    func testRenewVisitorIdEventWithOldVisitorId() {
        let event = Event(.renewVisitorId(old: "old_visitor_id", new: nil))

        XCTAssertEqual(event.eventName, .nativeAppRenewVisitorId, "eventName")
        XCTAssertEqual(event.values.count, 1, "values count")
        XCTAssertEqual(event.values.string(forKey: "old_visitor_id"), "old_visitor_id", "values.old_visitor_id")
    }

    func testRenewVisitorIdEventWithNewVisitorId() {
        let event = Event(.renewVisitorId(old: nil, new: "new_visitor_id"))

        XCTAssertEqual(event.values.count, 1, "values count")
        XCTAssertEqual(event.values.string(forKey: "new_visitor_id"), "new_visitor_id", "values.new_visitor_id")
    }
}
