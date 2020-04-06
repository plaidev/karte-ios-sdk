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

class DictionaryExtensionTests: XCTestCase {
    let date1 = Date()
    let date2 = Date()
    var dictionary: [String: JSONValue]!
    
    override func setUp() {
        let convertible: [String: JSONConvertible] = [
            "string": "foo",
            "integer": 100,
            "bool": true,
            "double": 100.5,
            "date": date1,
            "array": [[
                "string": "foo",
                "integer": 100,
                "bool": true,
                "double": 100.5,
                "date": date1,
                "array": [[
                    "string": "foo",
                    "integer": 100,
                    "bool": true,
                    "double": 100.5,
                    "date": date1
                ], [
                    "string": "bar",
                    "integer": 200,
                    "bool": false,
                    "double": 200.5,
                    "date": date2
                ]],
                "dictionary": [
                    "string": "foo",
                    "integer": 100,
                    "bool": true,
                    "double": 100.5,
                    "date": date1
                ]
            ], [
                "string": "bar",
                "integer": 200,
                "bool": false,
                "double": 200.5,
                "date": date1
            ]],
            "dictionary": [
                "string": "foo",
                "integer": 100,
                "bool": true,
                "double": 100.5,
                "date": date1,
                "array": [[
                    "string": "foo",
                    "integer": 100,
                    "bool": true,
                    "double": 100.5,
                    "date": date1
                ]],
                "dictionary": [
                    "string": "foo",
                    "integer": 100,
                    "bool": true,
                    "double": 100.5,
                    "date": date1
                ]
            ]
        ]        
        dictionary = convertible.mapValues { $0.jsonValue }
    }

    override func tearDown() {
    }

    func testGetValue() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(dictionary.string(forKey: "string"), "foo")
        XCTAssertEqual(dictionary.integer(forKey: "integer"), 100)
        XCTAssertEqual(dictionary.bool(forKey: "bool"), true)
        XCTAssertEqual(dictionary.double(forKey: "double"), 100.5)
        assertDateEqual(dictionary.date(forKey: "date"), date1)
        
        XCTAssertNotNil(dictionary.array(forKey: "array"))
        XCTAssertEqual(dictionary.string(forKeyPath: "array.0.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "array.0.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "array.0.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "array.0.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "array.0.date"), date1)
        XCTAssertNotNil(dictionary.array(forKeyPath: "array.0.array"))
        XCTAssertEqual(dictionary.string(forKeyPath: "array.0.array.0.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "array.0.array.0.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "array.0.array.0.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "array.0.array.0.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "array.0.array.0.date"), date1)
        XCTAssertNotNil(dictionary.dictionary(forKeyPath: "array.0.dictionary"))
        XCTAssertEqual(dictionary.string(forKeyPath: "array.0.dictionary.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "array.0.dictionary.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "array.0.dictionary.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "array.0.dictionary.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "array.0.dictionary.date"), date1)
        XCTAssertEqual(dictionary.string(forKeyPath: "array.1.string"), "bar")
        XCTAssertEqual(dictionary.integer(forKeyPath: "array.1.integer"), 200)
        XCTAssertEqual(dictionary.bool(forKeyPath: "array.1.bool"), false)
        XCTAssertEqual(dictionary.double(forKeyPath: "array.1.double"), 200.5)
        assertDateEqual(dictionary.date(forKeyPath: "array.1.date"), date2)
        
        XCTAssertNotNil(dictionary.dictionary(forKey: "dictionary"))
        XCTAssertEqual(dictionary.string(forKeyPath: "dictionary.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "dictionary.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "dictionary.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "dictionary.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "dictionary.date"), date1)
        XCTAssertNotNil(dictionary.array(forKeyPath: "dictionary.array"))
        XCTAssertEqual(dictionary.string(forKeyPath: "dictionary.array.0.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "dictionary.array.0.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "dictionary.array.0.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "dictionary.array.0.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "dictionary.array.0.date"), date1)
        XCTAssertNotNil(dictionary.dictionary(forKeyPath: "dictionary.dictionary"))
        XCTAssertEqual(dictionary.string(forKeyPath: "dictionary.dictionary.string"), "foo")
        XCTAssertEqual(dictionary.integer(forKeyPath: "dictionary.dictionary.integer"), 100)
        XCTAssertEqual(dictionary.bool(forKeyPath: "dictionary.dictionary.bool"), true)
        XCTAssertEqual(dictionary.double(forKeyPath: "dictionary.dictionary.double"), 100.5)
        assertDateEqual(dictionary.date(forKeyPath: "dictionary.dictionary.date"), date1)
    }
    
    func testFailedToGetValue() {
        XCTAssertNil(dictionary.string(forKey: "string_"))
        XCTAssertNil(dictionary.integer(forKey: "integer_"))
        XCTAssertNil(dictionary.bool(forKey: "bool_"))
        XCTAssertNil(dictionary.double(forKey: "double_"))
        XCTAssertNil(dictionary.date(forKey: "date_"))
        XCTAssertNil(dictionary.array(forKey: "array_"))
        XCTAssertNil(dictionary.dictionary(forKeyPath: "array.2"))
        XCTAssertNil(dictionary.string(forKeyPath: "array.0.string_"))
        XCTAssertNil(dictionary.integer(forKeyPath: "array.0.integer_"))
        XCTAssertNil(dictionary.bool(forKeyPath: "array.0.bool_"))
        XCTAssertNil(dictionary.double(forKeyPath: "array.0.double_"))
        XCTAssertNil(dictionary.date(forKeyPath: "array.0.date_"))
        XCTAssertNil(dictionary.array(forKeyPath: "array.0.array_"))
        XCTAssertNil(dictionary.dictionary(forKeyPath: "array.0.dictionary_"))
        XCTAssertNil(dictionary.dictionary(forKey: "dictionary_"))
        XCTAssertNil(dictionary.string(forKeyPath: "dictionary.string_"))
        XCTAssertNil(dictionary.integer(forKeyPath: "dictionary.integer_"))
        XCTAssertNil(dictionary.bool(forKeyPath: "dictionary.bool_"))
        XCTAssertNil(dictionary.double(forKeyPath: "dictionary.double_"))
        XCTAssertNil(dictionary.date(forKeyPath: "dictionary.date_"))
        XCTAssertNil(dictionary.array(forKeyPath: "dictionary.array_"))
        XCTAssertNil(dictionary.dictionary(forKeyPath: "dictionary.dictionary_"))
    }
}
