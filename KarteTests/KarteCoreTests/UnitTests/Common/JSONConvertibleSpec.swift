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

final class JSONConvertibleSpec: XCTestCase {

    // MARK: - mergeRecursive

    func testMergeRecursiveNoConflict() {
        var data: [String: any JSONConvertible] = ["f1": "f1v"]
        let ext: [String: any JSONConvertible] = ["f2": "f2v"]
        data.mergeRecursive(ext)

        XCTAssertEqual(data["f1"] as? String, "f1v", "f1 should remain f1v")
        XCTAssertEqual(data["f2"] as? String, "f2v", "f2 should be merged as f2v")
    }

    func testMergeRecursiveConflictPrimitiveValue() {
        var data: [String: any JSONConvertible] = ["f1": "f1v1"]
        let ext: [String: any JSONConvertible] = ["f1": "f1v2"]
        data.mergeRecursive(ext)

        XCTAssertEqual(data["f1"] as? String, "f1v2", "f1 should be overwritten to f1v2")
    }

    func testMergeRecursiveConflictDictionaryValue() {
        var data: [String: any JSONConvertible] = [
            "f1": [
                "f1a": [
                    "f1a1": "f1a1v1",
                    "f1a2": "f1a2v"
                ],
                "f1b": "f1bv"
            ],
            "f2": [
                "f2a": "f2av"
            ]
        ]
        let ext: [String: any JSONConvertible] = [
            "f1": [
                "f1a": [
                    "f1a1": "f1a1v2",
                    "f1a3": "f1a3v"
                ],
                "f1c": "f1cv"
            ],
            "f2": "f2v"
        ]
        data.mergeRecursive(ext)

        let v = data.mapValues { $0.jsonValue }
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a1"), "f1a1v2", "f1.f1a.f1a1 should be overwritten")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a2"), "f1a2v", "f1.f1a.f1a2 should remain")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a3"), "f1a3v", "f1.f1a.f1a3 should be merged")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1b"), "f1bv", "f1.f1b should remain")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1c"), "f1cv", "f1.f1c should be merged")
        XCTAssertEqual(v.string(forKeyPath: "f2"), "f2v", "f2 should be overwritten to primitive")
    }

    // MARK: - mergingRecursive

    func testMergingRecursiveNoConflict() {
        let base: [String: any JSONConvertible] = ["f1": "f1v"]
        let ext: [String: any JSONConvertible] = ["f2": "f2v"]
        let data = base.mergingRecursive(ext)

        XCTAssertEqual(data["f1"] as? String, "f1v", "f1 should be f1v")
        XCTAssertEqual(data["f2"] as? String, "f2v", "f2 should be merged as f2v")
        XCTAssertNil(base["f2"] as? String, "base should not be mutated")
    }

    func testMergingRecursiveConflictPrimitiveValue() {
        let base: [String: any JSONConvertible] = ["f1": "f1v1"]
        let ext: [String: any JSONConvertible] = ["f1": "f1v2"]
        let data = base.mergingRecursive(ext)

        XCTAssertEqual(data["f1"] as? String, "f1v2", "f1 should be overwritten to f1v2")
        XCTAssertEqual(base["f1"] as? String, "f1v1", "base f1 should not be mutated")
    }

    func testMergingRecursiveConflictDictionaryValue() {
        let base: [String: any JSONConvertible] = [
            "f1": [
                "f1a": [
                    "f1a1": "f1a1v1",
                    "f1a2": "f1a2v"
                ],
                "f1b": "f1bv"
            ],
            "f2": [
                "f2a": "f2av"
            ]
        ]
        let ext: [String: any JSONConvertible] = [
            "f1": [
                "f1a": [
                    "f1a1": "f1a1v2",
                    "f1a3": "f1a3v"
                ],
                "f1c": "f1cv"
            ],
            "f2": "f2v"
        ]
        let data = base.mergingRecursive(ext)

        let v = data.mapValues { $0.jsonValue }
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a1"), "f1a1v2", "f1.f1a.f1a1 should be overwritten")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a2"), "f1a2v", "f1.f1a.f1a2 should remain")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1a.f1a3"), "f1a3v", "f1.f1a.f1a3 should be merged")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1b"), "f1bv", "f1.f1b should remain")
        XCTAssertEqual(v.string(forKeyPath: "f1.f1c"), "f1cv", "f1.f1c should be merged")
        XCTAssertEqual(v.string(forKeyPath: "f2"), "f2v", "f2 should be overwritten to primitive")

        let bv = base.mapValues { $0.jsonValue }
        XCTAssertNil(bv.string(forKeyPath: "f1.f1a.f1a3"), "base f1.f1a.f1a3 should not exist")
        XCTAssertNil(bv.string(forKeyPath: "f1.f1c"), "base f1.f1c should not exist")
        XCTAssertEqual(bv.string(forKeyPath: "f2.f2a"), "f2av", "base f2.f2a should not be mutated")
    }
}
