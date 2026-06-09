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

class ViewEventSpec: XCTestCase {

    func testViewEventWhenViewIdIsNotNil() {
        let event = Event(.view(viewName: "view_name", title: "title", values: [
            "key": "value",
            "view_id": "view_id"
        ]))

        XCTAssertEqual(event.values.count, 4, "values count")
        XCTAssertEqual(event.values.string(forKey: "key"), "value", "values.key")
        XCTAssertEqual(event.values.string(forKey: "view_name"), "view_name", "values.view_name")
        XCTAssertEqual(event.values.string(forKey: "view_id"), "view_id", "values.view_id")
        XCTAssertEqual(event.values.string(forKey: "title"), "title", "values.title")
    }
}
