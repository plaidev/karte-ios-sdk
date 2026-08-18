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
import KarteCore
@testable import KarteVisualTracking

class LogicalOperatorSpec: XCTestCase {

    // when the number of conditions is one
    func testAndOneCondition() {
        let condition = Condition(name: .view, comparison: .eq("test"))
        let op = LogicalOperator.and([condition])
        let data: [String: JSONValue] = [
            Condition.CodingKeys.view.rawValue: .string("test")
        ]
        XCTAssertTrue(op.match(data: data), "one condition matches")
    }

    // when the number of conditions is two: all conditions are match
    func testAndTwoConditionsAllMatch() {
        let op = LogicalOperator.and([
            Condition(name: .os, comparison: .eq("test1")),
            Condition(name: .action, comparison: .eq("test2"))
        ])
        let data: [String: JSONValue] = [
            "app_info": .dictionary([
                "system_info": .dictionary([
                    "os": .string("test1")
                ])
            ]),
            Condition.CodingKeys.action.rawValue: .string("test2")
        ]
        XCTAssertTrue(op.match(data: data), "all conditions are match")
    }

    // when the number of conditions is two: not all conditions are match
    func testAndTwoConditionsNotAllMatch() {
        let op = LogicalOperator.and([
            Condition(name: .os, comparison: .eq("test1")),
            Condition(name: .action, comparison: .ne("test2"))
        ])
        let data: [String: JSONValue] = [
            "app_info": .dictionary([
                "system_info": .dictionary([
                    "os": .string("test1")
                ])
            ]),
            Condition.CodingKeys.action.rawValue: .string("test2")
        ]
        XCTAssertFalse(op.match(data: data), "not all conditions are match")
    }
}
