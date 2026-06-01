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

final class JSONConvertibleConverterSpec: XCTestCase {

    func testConvertNull() {
        let v = JSONConvertibleConverter.convert(Data()) as? NSNull
        XCTAssertEqual(v, NSNull(), "null")
    }

    func testConvertString() {
        let v = JSONConvertibleConverter.convert("foo") as? String
        XCTAssertEqual(v, "foo", "string")
    }

    func testConvertBool() {
        let v = JSONConvertibleConverter.convert(true) as? Bool
        XCTAssertEqual(v, true, "bool")
    }

    func testConvertInt() {
        let v = JSONConvertibleConverter.convert(1) as? Int
        XCTAssertEqual(v, 1, "int")
    }

    func testConvertUInt() {
        let v = JSONConvertibleConverter.convert(UInt.max) as? UInt
        XCTAssertEqual(v, UInt.max, "uint")
    }

    func testConvertDouble() {
        let v = JSONConvertibleConverter.convert(1.1) as? Double
        XCTAssertEqual(v, 1.1, "double")
    }

    func testConvertDate() {
        let d = Date(timeIntervalSince1970: 1)
        let v = JSONConvertibleConverter.convert(d) as? Date
        XCTAssertEqual(v?.timeIntervalSince1970, 1, "date")
    }

    func testConvertArray() {
        let v = JSONConvertibleConverter.convert([
            "foo",
            true,
            1,
            UInt.max,
            1.1,
            Date(timeIntervalSince1970: 1),
            [1],
            ["foo": "bar"],
            Data()
        ])
        XCTAssertEqual(v[0] as? String, "foo", "array[0] string")
        XCTAssertEqual(v[1] as? Bool, true, "array[1] bool")
        XCTAssertEqual(v[2] as? Int, 1, "array[2] int")
        XCTAssertEqual(v[3] as? UInt, UInt.max, "array[3] uint")
        XCTAssertEqual(v[4] as? Double, 1.1, "array[4] double")
        XCTAssertEqual((v[5] as? Date)?.timeIntervalSince1970, 1, "array[5] date")
        XCTAssertEqual((v[6] as? [Int])?[0] as? Int, 1, "array[6] nested array")
        XCTAssertEqual((v[7] as? [String: String])?["foo"] as? String, "bar", "array[7] nested dict")
        XCTAssertEqual(v[8] as? NSNull, NSNull(), "array[8] null")
    }

    func testConvertNSArray() {
        let array = NSArray(objects: "foo", true, 1, UInt.max, 1.1, Date(timeIntervalSince1970: 1), [1], ["foo": "bar"], Data())
        let v = JSONConvertibleConverter.convert(array) as! [JSONConvertible]
        XCTAssertEqual(v[0] as? String, "foo", "nsarray[0] string")
        XCTAssertEqual(v[1] as? Bool, true, "nsarray[1] bool")
        XCTAssertEqual(v[2] as? Int, 1, "nsarray[2] int")
        XCTAssertEqual(v[3] as? UInt, UInt.max, "nsarray[3] uint")
        XCTAssertEqual(v[4] as? Double, 1.1, "nsarray[4] double")
        XCTAssertEqual((v[5] as? Date)?.timeIntervalSince1970, 1, "nsarray[5] date")
        XCTAssertEqual((v[6] as? [Int])?[0] as? Int, 1, "nsarray[6] nested array")
        XCTAssertEqual((v[7] as? [String: String])?["foo"] as? String, "bar", "nsarray[7] nested dict")
        XCTAssertEqual(v[8] as? NSNull, NSNull(), "nsarray[8] null")
    }

    func testConvertDictionary() {
        let v = JSONConvertibleConverter.convert([
            "string": "foo",
            "bool": true,
            "int": 1,
            "uint": UInt.max,
            "double": 1.1,
            "date": Date(timeIntervalSince1970: 1),
            "array": [1],
            "dictionary": [
                "foo": "bar"
            ],
            "null": Data()
        ])
        XCTAssertEqual(v["string"] as? String, "foo", "dict string")
        XCTAssertEqual(v["bool"] as? Bool, true, "dict bool")
        XCTAssertEqual(v["int"] as? Int, 1, "dict int")
        XCTAssertEqual(v["uint"] as? UInt, UInt.max, "dict uint")
        XCTAssertEqual(v["double"] as? Double, 1.1, "dict double")
        XCTAssertEqual((v["date"] as? Date)?.timeIntervalSince1970, 1, "dict date")
        XCTAssertEqual((v["array"] as? [Int])?[0] as? Int, 1, "dict nested array")
        XCTAssertEqual((v["dictionary"] as? [String: String])?["foo"] as? String, "bar", "dict nested dict")
        XCTAssertEqual(v["null"] as? NSNull, NSNull(), "dict null")
    }

    func testConvertAnyHashableDictionary() {
        let dictionary: [AnyHashable: Any] = [
            "string": "foo",
            "bool": true,
            "int": 1,
            "uint": UInt.max,
            "double": 1.1,
            "date": Date(timeIntervalSince1970: 1),
            "array": [1],
            "dictionary": [
                "foo": "bar"
            ],
            "null": Data()
        ]
        let v = JSONConvertibleConverter.convert(dictionary)
        XCTAssertEqual(v["string"] as? String, "foo", "anyhashable dict string")
        XCTAssertEqual(v["bool"] as? Bool, true, "anyhashable dict bool")
        XCTAssertEqual(v["int"] as? Int, 1, "anyhashable dict int")
        XCTAssertEqual(v["uint"] as? UInt, UInt.max, "anyhashable dict uint")
        XCTAssertEqual(v["double"] as? Double, 1.1, "anyhashable dict double")
        XCTAssertEqual((v["date"] as? Date)?.timeIntervalSince1970, 1, "anyhashable dict date")
        XCTAssertEqual((v["array"] as? [Int])?[0] as? Int, 1, "anyhashable dict nested array")
        XCTAssertEqual((v["dictionary"] as? [String: String])?["foo"] as? String, "bar", "anyhashable dict nested dict")
        XCTAssertEqual(v["null"] as? NSNull, NSNull(), "anyhashable dict null")
    }

    func testConvertNSDictionary() {
        let dictionary = NSDictionary(dictionary: [
            "string": "foo",
            "bool": true,
            "int": 1,
            "uint": UInt.max,
            "double": 1.1,
            "date": Date(timeIntervalSince1970: 1),
            "array": [1],
            "dictionary": [
                "foo": "bar"
            ],
            "null": NSNull()
        ])
        let v = JSONConvertibleConverter.convert(dictionary) as! [String: JSONConvertible]
        XCTAssertEqual(v["string"] as? String, "foo", "nsdict string")
        XCTAssertEqual(v["bool"] as? Bool, true, "nsdict bool")
        XCTAssertEqual(v["int"] as? Int, 1, "nsdict int")
        XCTAssertEqual(v["uint"] as? UInt, UInt.max, "nsdict uint")
        XCTAssertEqual(v["double"] as? Double, 1.1, "nsdict double")
        XCTAssertEqual((v["date"] as? Date)?.timeIntervalSince1970, 1, "nsdict date")
        XCTAssertEqual((v["array"] as? [Int])?[0] as? Int, 1, "nsdict nested array")
        XCTAssertEqual((v["dictionary"] as? [String: String])?["foo"] as? String, "bar", "nsdict nested dict")
        XCTAssertEqual(v["null"] as? NSNull, NSNull(), "nsdict null")
    }
}
