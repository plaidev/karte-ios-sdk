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

import Quick
import Nimble
@testable import KarteCore

final class JSONConvertibleConverterSpec: QuickSpec {

    override class func spec() {
        describe("convert") {
            it("null") {
                let v = JSONConvertibleConverter.convert(Data()) as? NSNull
                expect(v).to(equal(NSNull()))
            }
            it("string") {
                let v = JSONConvertibleConverter.convert("foo") as? String
                expect(v).to(equal("foo"))
            }
            it("bool") {
                let v = JSONConvertibleConverter.convert(true) as? Bool
                expect(v).to(beTrue())
            }
            it("int") {
                let v = JSONConvertibleConverter.convert(1) as? Int
                expect(v).to(equal(1))
            }
            it("uint") {
                let v = JSONConvertibleConverter.convert(UInt.max) as? UInt
                expect(v).to(equal(UInt.max))
            }
            it("double") {
                let v = JSONConvertibleConverter.convert(1.1) as? Double
                expect(v).to(equal(1.1))
            }
            it("date") {
                let d = Date(timeIntervalSince1970: 1)
                let v = JSONConvertibleConverter.convert(d) as? Date
                expect(v?.timeIntervalSince1970).to(equal(1))
            }
            it("array") {
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
                expect(v[0] as? String).to(equal("foo"))
                expect(v[1] as? Bool).to(beTrue())
                expect(v[2] as? Int).to(equal(1))
                expect(v[3] as? UInt).to(equal(UInt.max))
                expect(v[4] as? Double).to(equal(1.1))
                expect((v[5] as? Date)?.timeIntervalSince1970).to(equal(1))
                expect((v[6] as? [Int])?[0] as? Int).to(equal(1))
                expect((v[7] as? [String: String])?["foo"] as? String).to(equal("bar"))
                expect(v[8] as? NSNull).to(equal(NSNull()))
            }
            it("nsarray") {
                let array = NSArray(objects: "foo", true, 1, UInt.max, 1.1, Date(timeIntervalSince1970: 1), [1], ["foo": "bar"], Data())
                let v = JSONConvertibleConverter.convert(array) as! [JSONConvertible]
                expect(v[0] as? String).to(equal("foo"))
                expect(v[1] as? Bool).to(beTrue())
                expect(v[2] as? Int).to(equal(1))
                expect(v[3] as? UInt).to(equal(UInt.max))
                expect(v[4] as? Double).to(equal(1.1))
                expect((v[5] as? Date)?.timeIntervalSince1970).to(equal(1))
                expect((v[6] as? [Int])?[0] as? Int).to(equal(1))
                expect((v[7] as? [String: String])?["foo"] as? String).to(equal("bar"))
                expect(v[8] as? NSNull).to(equal(NSNull()))
            }
            it("dictionary") {
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
                expect(v["string"] as? String).to(equal("foo"))
                expect(v["bool"] as? Bool).to(beTrue())
                expect(v["int"] as? Int).to(equal(1))
                expect(v["uint"] as? UInt).to(equal(UInt.max))
                expect(v["double"] as? Double).to(equal(1.1))
                expect((v["date"] as? Date)?.timeIntervalSince1970).to(equal(1))
                expect((v["array"] as? [Int])?[0] as? Int).to(equal(1))
                expect((v["dictionary"] as? [String: String])?["foo"] as? String).to(equal("bar"))
                expect(v["null"] as? NSNull).to(equal(NSNull()))
            }
            it("dictionary 2") {
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
                expect(v["string"] as? String).to(equal("foo"))
                expect(v["bool"] as? Bool).to(beTrue())
                expect(v["int"] as? Int).to(equal(1))
                expect(v["uint"] as? UInt).to(equal(UInt.max))
                expect(v["double"] as? Double).to(equal(1.1))
                expect((v["date"] as? Date)?.timeIntervalSince1970).to(equal(1))
                expect((v["array"] as? [Int])?[0] as? Int).to(equal(1))
                expect((v["dictionary"] as? [String: String])?["foo"] as? String).to(equal("bar"))
                expect(v["null"] as? NSNull).to(equal(NSNull()))
            }
            it("nsdictionary") {
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
                expect(v["string"] as? String).to(equal("foo"))
                expect(v["bool"] as? Bool).to(beTrue())
                expect(v["int"] as? Int).to(equal(1))
                expect(v["uint"] as? UInt).to(equal(UInt.max))
                expect(v["double"] as? Double).to(equal(1.1))
                expect((v["date"] as? Date)?.timeIntervalSince1970).to(equal(1))
                expect((v["array"] as? [Int])?[0] as? Int).to(equal(1))
                expect((v["dictionary"] as? [String: String])?["foo"] as? String).to(equal("bar"))
                expect(v["null"] as? NSNull).to(equal(NSNull()))
            }
        }
    }
}
