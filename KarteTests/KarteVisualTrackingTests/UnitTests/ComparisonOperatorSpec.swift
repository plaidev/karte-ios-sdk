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
@testable import KarteVisualTracking

class ComparisonOperatorSpec: XCTestCase {

    func testEq() {
        let op: ComparisonOperator = .eq("test")
        XCTAssertTrue(op.match(value: "test"), "return true when passing `test`")
        XCTAssertFalse(op.match(value: "TEST"), "return false when passing `TEST`")
        XCTAssertFalse(op.match(value: "foo"), "return false when passing `foo`")
    }

    func testNe() {
        let op: ComparisonOperator = .ne("test")
        XCTAssertFalse(op.match(value: "test"), "return false when passing `test`")
        XCTAssertTrue(op.match(value: "TEST"), "return true when passing `TEST`")
        XCTAssertTrue(op.match(value: "foo"), "return true when passing `foo`")
    }

    func testStartsWith() {
        let op: ComparisonOperator = .startsWith("te")
        XCTAssertTrue(op.match(value: "test"), "return true when passing `test`")
        XCTAssertFalse(op.match(value: "TEST"), "return false when passing `TEST`")
        XCTAssertFalse(op.match(value: "foo"), "return false when passing `foo`")
    }

    func testEndsWith() {
        let op: ComparisonOperator = .endsWith("st")
        XCTAssertTrue(op.match(value: "test"), "return true when passing `test`")
        XCTAssertFalse(op.match(value: "TEST"), "return false when passing `TEST`")
        XCTAssertFalse(op.match(value: "foo"), "return false when passing `foo`")
    }

    func testContains() {
        let op: ComparisonOperator = .contains("es")
        XCTAssertTrue(op.match(value: "test"), "return true when passing `test`")
        XCTAssertFalse(op.match(value: "TEST"), "return false when passing `TEST`")
        XCTAssertFalse(op.match(value: "foo"), "return false when passing `foo`")
    }
}
