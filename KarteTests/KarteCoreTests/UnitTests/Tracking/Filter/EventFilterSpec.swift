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
import KarteUtilities
@testable import KarteCore

class EventFilterSpec: XCTestCase {

    func testEmptyEventNameFilterRule() {
        let filter = EventFilter.Builder().add(EmptyEventNameFilterRule()).build()

        XCTAssertThrowsError(try filter.filter(Event(eventName: EventName(""))), "empty event name should throw")
        XCTAssertNoThrow(try filter.filter(Event(.open)), "nativeAppOpen should not throw")
    }

    func testNonAsciiEventNameFilterRule() {
        let filter = EventFilter.Builder().add(NonAsciiEventNameFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("イベント"))), "non-ascii event name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("event"))), "ascii event name should not throw")
    }

    func testUnretryableEventOnline() {
        let filter = EventFilter.Builder().add(UnretryableEventFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("_fetch_variables"))), "unretryable event online should not throw")
    }

    func testUnretryableEventOffline() {
        let filter = EventFilter.Builder().add(UnretryableEventFilterRule()).build()

        Resolver.root = Resolver.submock
        Resolver.root.register(Bool.self, name: "isReachable") {
            false
        }
        defer {
            Resolver.root = Resolver.mock
        }

        XCTAssertThrowsError(try filter.filter(Event(eventName: EventName("_fetch_variables"))), "unretryable event offline should throw")
    }

    func testRetryableEventOnline() {
        let filter = EventFilter.Builder().add(UnretryableEventFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("event"))), "retryable event online should not throw")
    }

    func testRetryableEventOffline() {
        let filter = EventFilter.Builder().add(UnretryableEventFilterRule()).build()

        Resolver.root = Resolver.submock
        Resolver.root.register(Bool.self, name: "isReachable") {
            false
        }
        defer {
            Resolver.root = Resolver.mock
        }

        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("event"))), "retryable event offline should not throw")
    }

    func testInitializationEventFilterRule() {
        let filter = EventFilter.Builder().add(InitializationEventFilterRule()).build()

        XCTAssertThrowsError(try filter.filter(Event(.open)), "initialization event should throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("event"))), "non-initialization event should not throw")
    }

    func testInvalidEventNameFilterRule() {
        let filter = EventFilter.Builder().add(InvalidEventNameFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("Hoge"))), "uppercase event name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("event-name"))), "hyphenated event name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("_test"))), "underscore-prefixed event name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("test_0123"))), "valid event name should not throw")
    }

    func testInvalidEventFieldNameFilterRule() {
        let filter = EventFilter.Builder().add(InvalidEventFieldNameFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(eventName: .view, values: ["test.1": "invalid field name"])), "dot in field name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: .view, values: ["$test": "invalid field name"])), "dollar in field name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: .view, values: ["count": 10])), "count field name should not throw")
    }

    func testInvalidEventFieldValueFilterRule() {
        let filter = EventFilter.Builder().add(InvalidEventFieldValueFilterRule()).build()

        XCTAssertNoThrow(try filter.filter(Event(.view(viewName: "", title: "title", values: [:]))), "empty view_name should not throw")
        XCTAssertNoThrow(try filter.filter(Event(.identify(userId: "", values: [:]))), "empty user_id should not throw")
        XCTAssertNoThrow(try filter.filter(Event(eventName: EventName("identify"), values: [:])), "nil user_id should not throw")
    }
}
