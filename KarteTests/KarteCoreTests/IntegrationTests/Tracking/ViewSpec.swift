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

class ViewSpec: XCTestCase {

    func testViewWithViewIdAndTitle() {
        let num = 100
        let str = "foo"
        let bool = true
        let date = Date(timeIntervalSince1970: 1577836800.123)
        let dictValue = "value"
        let dict: [String: JSONConvertible] = ["key": dictValue]
        let arrValue1 = "value1"
        let arrValue2 = "value2"
        let arr: [JSONConvertible] = [arrValue1, arrValue2]
        let values: [String: JSONConvertible] = [
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

        Tracker.view(
            "view_name",
            title: "title",
            values: values.merging(["view_id": "view_id"]) { $1 }
        )

        guard let event = module.wait().event(.view) else {
            XCTFail("event for view should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .view, "event name")
        XCTAssertEqual(event.values.string(forKey: field(.viewName)), "view_name", "values.view_name")
        XCTAssertEqual(event.values.string(forKey: field(.viewId)), "view_id", "values.view_id")
        XCTAssertEqual(event.values.string(forKey: field(.title)), "title", "values.title")
        XCTAssertEqual(event.values.integer(forKey: "num"), num, "values.num")
        XCTAssertEqual(event.values.string(forKey: "str"), str, "values.str")
        XCTAssertEqual(event.values.bool(forKey: "bool"), true, "values.bool")
        XCTAssertEqual(event.values.date(forKey: "date"), date, "values.date")
        XCTAssertEqual(event.values.string(forKeyPath: "arr.0"), arrValue1, "values.arr.0")
        XCTAssertEqual(event.values.string(forKeyPath: "arr.1"), arrValue2, "values.arr.1")
        XCTAssertEqual(event.values.string(forKeyPath: "dict.key"), dictValue, "values.dict.key")
        XCTAssertNotNil(event.values.date(forKey: field(.localEventDate)), "values._local_event_date should not be nil")
        XCTAssertNil(event.values.bool(forKey: field(.retry)), "values._retry should be nil")
    }

    func testViewWithoutViewIdAndTitle() {
        let num = 100
        let str = "foo"
        let bool = true
        let date = Date(timeIntervalSince1970: 1577836800.123)
        let dictValue = "value"
        let dict: [String: JSONConvertible] = ["key": dictValue]
        let arrValue1 = "value1"
        let arrValue2 = "value2"
        let arr: [JSONConvertible] = [arrValue1, arrValue2]
        let values: [String: JSONConvertible] = [
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

        Tracker.view("view_name", title: nil, values: values)

        guard let event = module.wait().event(.view) else {
            XCTFail("event for view should not be nil")
            return
        }

        XCTAssertEqual(event.values.string(forKey: field(.viewName)), "view_name", "values.view_name")
        XCTAssertNil(event.values.string(forKey: field(.viewId)), "values.view_id should be nil")
        XCTAssertEqual(event.values.string(forKey: field(.title)), "view_name", "values.title should fallback to view_name")
    }
}
