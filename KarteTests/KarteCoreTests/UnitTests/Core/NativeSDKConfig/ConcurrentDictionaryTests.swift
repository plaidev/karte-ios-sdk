//
//  Copyright 2026 PLAID, Inc.
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

class ConcurrentDictionaryTests: XCTestCase {
    func testValue() {
        let dict = ConcurrentDictionary(["flag": false])
        XCTAssertFalse(dict.value(forKey: "flag", default: true))
        XCTAssertTrue(dict.value(forKey: "missing", default: true))
        XCTAssertFalse(dict.value(forKey: "missing", default: false))
    }

    func testUpdateAll() {
        let dict = ConcurrentDictionary(["old": "exists"])
        dict.updateAll(["new": "value"])
        XCTAssertEqual(dict.value(forKey: "old", default: "default"), "default")
        XCTAssertEqual(dict.value(forKey: "new", default: "default"), "value")
    }

    func testConcurrentUpdateAllAndReadsDoNotCrash() {
        let dict = ConcurrentDictionary<String, Int>()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "io.karte.test.ConcurrentDictionaryTests", attributes: .concurrent)

        for i in 0..<100 {
            group.enter()
            queue.async {
                dict.updateAll(["flag": i])
                group.leave()
            }
            group.enter()
            queue.async {
                _ = dict.value(forKey: "flag", default: 0)
                group.leave()
            }
        }
        group.wait() // Waits for all asynchronous tasks to complete.
    }
}
