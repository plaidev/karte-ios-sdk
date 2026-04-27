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

class IdentifyEventSpec: XCTestCase {

    func testIdentifyEvent() {
        let event = Event(.identify(userId: "test_user", values: [
            "key": "value"
        ]))

        XCTAssertEqual(event.eventName, .identify, "eventName")
        XCTAssertNotNil(event.values, "values should not be nil")
        XCTAssertEqual(event.values.count, 2, "values count")
        XCTAssertEqual(event.values.string(forKey: "user_id"), "test_user", "values.user_id")
        XCTAssertEqual(event.values.string(forKey: "key"), "value", "values.key")
    }
}
