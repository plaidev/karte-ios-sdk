//
//  Copyright 2024 PLAID, Inc.
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

class RequestATTCommandSpec: XCTestCase {

    func testRunReturnsFalseForInvalidURLs() {
        let inputs = [
            "test:",
            "krt:",
            "krt://request-att",
            "aaa-karte-sdk://request-att",
            "krt-hSZM://request-att",
            "krt-hSZMcVyjwg6Y7pdYMa4YPqmyQ77EpALw://request-review",
        ]
        for input in inputs {
            let c = RequestATTCommand()
            let u = URL(string: input)!
            XCTAssertFalse(c.run(url: u), "\(input) returns false")
        }
    }

    func testRunReturnsTrueForValidURLs() {
        let inputs = [
            "krt-hSZMcVyjwg6Y7pdYMa4YPqmyQ77EpALw://request-att",
            "krt-HRTwj9QEZGJrTaTkADrtdxFTyuXUJVMh://request-att",
        ]
        for input in inputs {
            let c = RequestATTCommand()
            let u = URL(string: input)!
            XCTAssertTrue(c.run(url: u), "\(input) returns true")
        }
    }
}
