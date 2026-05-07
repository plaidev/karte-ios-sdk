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
@testable import KarteCore

class TrackEventRejectionFilterSpec: XCTestCase {

    func testRejectFilter() {
        var filter = TrackEventRejectionFilter()
        filter.add(rule: TestRule(libraryName: "m1", eventName: EventName("e1"), value: "v1"))

        let matchedValue = Event(eventName: EventName("e1"), values: ["f1": "v1"], libraryName: "m1")
        XCTAssertFalse(filter.reject(event: matchedValue), "should not reject when value matches")

        let mismatchedValue = Event(eventName: EventName("e1"), values: ["f1": "v2"], libraryName: "m1")
        XCTAssertTrue(filter.reject(event: mismatchedValue), "should reject when value does not match")

        let wrongLibrary = Event(eventName: EventName("e1"), values: ["f1": "v1"], libraryName: "m2")
        XCTAssertFalse(filter.reject(event: wrongLibrary), "should not reject when libraryName does not match")

        let wrongEvent = Event(eventName: EventName("e2"), values: ["f1": "v1"], libraryName: "m1")
        XCTAssertFalse(filter.reject(event: wrongEvent), "should not reject when eventName does not match")
    }
}

extension TrackEventRejectionFilterSpec {
    struct TestRule: TrackEventRejectionFilterRule {
        var libraryName: String
        var eventName: EventName
        var value: String

        init(libraryName: String, eventName: EventName, value: String) {
            self.libraryName = libraryName
            self.eventName = eventName
            self.value = value
        }

        func reject(event: Event) -> Bool {
            return event.values.string(forKeyPath: "f1") != value
        }
    }
}
