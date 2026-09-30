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

import Foundation
import XCTest
import KarteUtilities

final class UserDefaultsTests: XCTestCase {
    private let variablesRootKey = "io.karte.variables"
    private let configRootKey = "io.karte.config"

    private func makeUserDefaults(suiteName: String) -> UserDefaults {
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        return userDefaults
    }

    func testSet() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["existing": 1], forKey: variablesRootKey)

        let key = UserDefaultsKey("target", forNamespace: .variables)
        userDefaults.set(2, forKey: key)
        let rootAfterSet = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(rootAfterSet.count, 2)
        XCTAssertEqual(rootAfterSet["existing"] as? Int, 1)
        XCTAssertEqual(rootAfterSet["target"] as? Int, 2)

        // NOTE: nilをsetすると、キー自体が除去されることのテスト
        userDefaults.set(nil, forKey: key)
        let rootAfterRemoval = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(rootAfterRemoval.count, 1)
        XCTAssertEqual(rootAfterRemoval["existing"] as? Int, 1)
    }

    func testBulkSet() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["existing": 1, "removed": 2], forKey: variablesRootKey)

        userDefaults.bulkSet(["added": 3, "removed": nil], forNameSpace: .variables)

        let root = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(root.count, 2)
        XCTAssertEqual(root["existing"] as? Int, 1)
        XCTAssertEqual(root["added"] as? Int, 3)
    }

    func testObjectForKey() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["target": 1], forKey: variablesRootKey)
        userDefaults.set(["target": 2], forKey: configRootKey)
        let key = UserDefaultsKey("target", forNamespace: .variables)

        XCTAssertEqual(userDefaults.object(forKey: key) as? Int, 1)
        XCTAssertNil(userDefaults.object(forKey: UserDefaultsKey("missing", forNamespace: .variables)))
    }

    func testGetAllKeys() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["first": 1, "second": 2], forKey: variablesRootKey)
        userDefaults.set(["other": 3], forKey: configRootKey)

        XCTAssertEqual(Set(userDefaults.getAllKeys(forNamespace: .variables)), ["first", "second"])
    }

    func testContains() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["present": 1], forKey: variablesRootKey)

        XCTAssertTrue(userDefaults.contains(forKey: UserDefaultsKey("present", forNamespace: .variables)))
        XCTAssertFalse(userDefaults.contains(forKey: UserDefaultsKey("missing", forNamespace: .variables)))
    }

    func testRemoveObjectForKey() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["removed": 1, "retained": 2], forKey: variablesRootKey)

        userDefaults.removeObject(forKey: UserDefaultsKey("removed", forNamespace: .variables))

        let root = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(root.count, 1)
        XCTAssertEqual(root["retained"] as? Int, 2)
    }

    func testRemoveObjectForNamespace() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        userDefaults.set(["shared": 1], forKey: variablesRootKey)
        userDefaults.set(["shared": 2], forKey: configRootKey)

        userDefaults.removeObject(forNamespace: .variables)

        XCTAssertNil(userDefaults.dictionary(forKey: variablesRootKey))
        let configRoot = userDefaults.dictionary(forKey: configRootKey)!
        XCTAssertEqual(configRoot["shared"] as? Int, 2)
    }

    func testConcurrentSet() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        let iterations = 100

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            userDefaults.set(index, forKey: UserDefaultsKey("key-\(index)", forNamespace: .variables))
        }

        let root = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(root.count, iterations)
        for index in 0..<iterations {
            XCTAssertEqual(root["key-\(index)"] as? Int, index)
        }
    }

    func testConcurrentBulkSet() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        let iterations = 100

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            userDefaults.bulkSet(["key-\(index)": index], forNameSpace: .variables)
        }

        let root = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(root.count, iterations)
        for index in 0..<iterations {
            XCTAssertEqual(root["key-\(index)"] as? Int, index)
        }
    }

    func testConcurrentRemoveObjectForKey() {
        let userDefaults = makeUserDefaults(suiteName: "io.karte.UserDefaultsTests.\(#function)")
        let iterations = 100
        let initialValues = Dictionary(uniqueKeysWithValues: (0...iterations).map { ("key-\($0)", $0) })
        userDefaults.set(initialValues, forKey: variablesRootKey)

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            userDefaults.removeObject(forKey: UserDefaultsKey("key-\(index)", forNamespace: .variables))
        }

        let root = userDefaults.dictionary(forKey: variablesRootKey)!
        XCTAssertEqual(root.count, 1)
        XCTAssertEqual(root["key-\(iterations)"] as? Int, iterations)
    }
}
