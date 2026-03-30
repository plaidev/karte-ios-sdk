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

class IdentifySpec: XCTestCase {

    private let userId = "test_user"
    private let num = 100
    private let str = "foo"
    private let bool = true
    private let date = Date()
    private let dictValue = "value"
    private let arrValue1 = "value1"
    private let arrValue2 = "value2"

    private var values: [String: JSONConvertible] {
        let dict: [String: JSONConvertible] = ["key": dictValue]
        let arr: [JSONConvertible] = [arrValue1, arrValue2]
        return [
            "num": num,
            "str": str,
            "bool": bool,
            "date": date,
            "arr": arr,
            "dict": dict
        ]
    }

    private func makeConfiguration() -> KarteCore.Configuration {
        Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
    }

    private func makeBuilder() -> Builder {
        StubBuilder(spec: Self.self, resource: .empty).build()
    }

    private func assertIdentifyEvent(_ event: Event) {
        XCTAssertEqual(event.eventName, .identify, "event name")
        XCTAssertEqual(event.values.string(forKey: "user_id"), userId, "values.user_id")
        XCTAssertEqual(event.values.integer(forKey: "num"), num, "values.num")
        XCTAssertEqual(event.values.string(forKey: "str"), str, "values.str")
        XCTAssertEqual(event.values.bool(forKey: "bool"), true, "values.bool")
        if let eventDate = event.values.date(forKey: "date") {
            XCTAssertEqual(eventDate.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.0001, "values.date")
        } else {
            XCTFail("values.date should not be nil")
        }
        XCTAssertEqual(event.values.string(forKeyPath: "arr.0"), arrValue1, "values.arr.0")
        XCTAssertEqual(event.values.string(forKeyPath: "arr.1"), arrValue2, "values.arr.1")
        XCTAssertEqual(event.values.string(forKeyPath: "dict.key"), dictValue, "values.dict.key")
        XCTAssertNotNil(event.values.date(forKey: field(.localEventDate)), "values._local_event_date should not be nil")
        XCTAssertNil(event.values.bool(forKey: field(.retry)), "values._retry should be nil")
    }

    func testIdentify() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.track(event: Event(.identify(userId: userId, values: values)))

        guard let event = module.wait().event(.identify) else {
            XCTFail("identify event should not be nil")
            return
        }
        assertIdentifyEvent(event)
    }

    func testIdentifyCompatible() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.identify(userId, values)

        guard let event = module.wait().event(.identify) else {
            XCTFail("identify event should not be nil")
            return
        }
        assertIdentifyEvent(event)
    }
}
