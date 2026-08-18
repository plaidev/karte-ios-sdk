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

final class JSONValueSpec: XCTestCase {

    // MARK: - mergeRecursive

    func testMergeRecursiveNoConflict() {
        var data: [String: JSONValue] = ["f1": "f1v"].mapValues { $0.jsonValue }
        let ext: [String: JSONValue] = ["f2": "f2v"].mapValues { $0.jsonValue }
        data.mergeRecursive(ext)

        XCTAssertEqual(data.string(forKeyPath: "f1"), "f1v", "f1")
        XCTAssertEqual(data.string(forKeyPath: "f2"), "f2v", "f2")
    }

    func testMergeRecursiveConflictPrimitiveValue() {
        var data: [String: JSONValue] = ["f1": "f1v1"].mapValues { $0.jsonValue }
        let ext: [String: JSONValue] = ["f1": "f1v2"].mapValues { $0.jsonValue }
        data.mergeRecursive(ext)

        XCTAssertEqual(data.string(forKeyPath: "f1"), "f1v2", "f1")
    }

    func testMergeRecursiveConflictDictionaryValue() {
        var data: [String: JSONValue] = [
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
        ].mapValues { $0.jsonValue }

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
        data.mergeRecursive(ext.mapValues { $0.jsonValue })

        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a1"), "f1a1v2", "f1.f1a.f1a1")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a2"), "f1a2v", "f1.f1a.f1a2")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a3"), "f1a3v", "f1.f1a.f1a3")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1b"), "f1bv", "f1.f1b")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1c"), "f1cv", "f1.f1c")
        XCTAssertEqual(data.string(forKeyPath: "f2"), "f2v", "f2")
    }

    // MARK: - mergingRecursive

    func testMergingRecursiveNoConflict() {
        let base: [String: JSONValue] = ["f1": "f1v"].mapValues { $0.jsonValue }
        let ext: [String: JSONValue] = ["f2": "f2v"].mapValues { $0.jsonValue }
        let data = base.mergingRecursive(ext)

        XCTAssertEqual(data.string(forKeyPath: "f1"), "f1v", "f1")
        XCTAssertEqual(data.string(forKeyPath: "f2"), "f2v", "f2")
        XCTAssertNil(base.string(forKeyPath: "f2"), "base f2 is nil")
    }

    func testMergingRecursiveConflictPrimitiveValue() {
        let base: [String: JSONValue] = ["f1": "f1v1"].mapValues { $0.jsonValue }
        let ext: [String: JSONValue] = ["f1": "f1v2"].mapValues { $0.jsonValue }
        let data = base.mergingRecursive(ext)

        XCTAssertEqual(data.string(forKeyPath: "f1"), "f1v2", "f1")
        XCTAssertEqual(base.string(forKeyPath: "f1"), "f1v1", "base.f1")
    }

    func testMergingRecursiveConflictDictionaryValue() {
        let base: [String: JSONValue] = [
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
        ].mapValues { $0.jsonValue }

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
        let data = base.mergingRecursive(ext.mapValues { $0.jsonValue })

        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a1"), "f1a1v2", "f1.f1a.f1a1")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a2"), "f1a2v", "f1.f1a.f1a2")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1a.f1a3"), "f1a3v", "f1.f1a.f1a3")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1b"), "f1bv", "f1.f1b")
        XCTAssertEqual(data.string(forKeyPath: "f1.f1c"), "f1cv", "f1.f1c")
        XCTAssertEqual(data.string(forKeyPath: "f2"), "f2v", "f2")
        XCTAssertNil(base.string(forKeyPath: "f1.f1a.f1a3"), "base f1.f1a.f1a3 is nil")
        XCTAssertNil(base.string(forKeyPath: "f1.f1c"), "base f1.f1c is nil")
        XCTAssertEqual(base.string(forKeyPath: "f2.f2a"), "f2av", "base f2.f2a")
    }
}
