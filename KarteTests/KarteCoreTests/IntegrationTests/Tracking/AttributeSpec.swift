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

class AttributeSpec: XCTestCase {

    func testAttribute() throws {
        try performAttributeTest { values in
            Tracker.track(event: Event(.attribute(values: values)))
        }
    }

    func testAttributeCompatible() throws {
        try performAttributeTest { values in
            Tracker.attribute(values)
        }
    }

    private func performAttributeTest(trackAction: ([String: any JSONConvertible]) -> Void) throws {
        let num = 100
        let str = "foo"
        let bool = true
        let date = Date()
        let dictValue = "value"
        let dict: [String: any JSONConvertible] = ["key": dictValue]
        let arrValue1 = "value1"
        let arrValue2 = "value2"
        let arr: [any JSONConvertible] = [arrValue1, arrValue2]
        let values: [String: any JSONConvertible] = [
            "num": num,
            "str": str,
            "bool": bool,
            "date": date,
            "arr": arr,
            "dict": dict
        ]

        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        trackAction(values)

        guard let event = module.wait().event(.attribute) else {
            XCTFail("event for 'attribute' should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .attribute, "event name")
        XCTAssertEqual(event.values.integer(forKey: "num"), num, "values.num")
        XCTAssertEqual(event.values.string(forKey: "str"), str, "values.str")
        XCTAssertEqual(event.values.bool(forKey: "bool"), true, "values.bool")
        let eventDate = try XCTUnwrap(event.values.date(forKey: "date"), "values.date should not be nil")
        XCTAssertEqual(eventDate.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.0001, "values.date")
        XCTAssertEqual(event.values.string(forKeyPath: "arr.0"), arrValue1, "values.arr.0")
        XCTAssertEqual(event.values.string(forKeyPath: "arr.1"), arrValue2, "values.arr.1")
        XCTAssertEqual(event.values.string(forKeyPath: "dict.key"), dictValue, "values.dict.key")
        XCTAssertNotNil(event.values.date(forKey: field(.localEventDate)), "values._local_event_date should not be nil")
        XCTAssertNil(event.values.bool(forKey: field(.retry)), "values._retry should be nil")
    }
}
