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

final class JSONValueSpec: QuickSpec {
    override func spec() {
        describe("a merge recursive") {
            context("no conflict") {
                var data: [String: JSONValue] = ["f1": "f1v"].mapValues { $0.jsonValue }

                beforeSuite {
                    let ext: [String: JSONValue] = ["f2": "f2v"].mapValues { $0.jsonValue }
                    data.mergeRecursive(ext)
                }

                it("f1 is `f1v`") {
                    expect(data.string(forKeyPath: "f1")).to(equal("f1v"))
                }

                it("f2 is `f2v`") {
                    expect(data.string(forKeyPath: "f2")).to(equal("f2v"))
                }
            }

            context("conflict premitive value") {
                var data: [String: JSONValue] = ["f1": "f1v1"].mapValues { $0.jsonValue }

                beforeSuite {
                    let ext: [String: JSONValue] = ["f1": "f1v2"].mapValues { $0.jsonValue }
                    data.mergeRecursive(ext)
                }

                it("f1 is `f1v2`") {
                    expect(data.string(forKeyPath: "f1")).to(equal("f1v2"))
                }
            }

            context("conflict dictionary value") {
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
                
                beforeSuite {
                    let ext: [String: JSONConvertible] = [
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
                }

                it("f1.f1a.f1a1 is `f1a1v2`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a1")).to(equal("f1a1v2"))
                }

                it("f1.f1a.f1a2 is `f1a2v`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a2")).to(equal("f1a2v"))
                }

                it("f1.f1a.f1a3 is `f1a3v`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a3")).to(equal("f1a3v"))
                }

                it("f1.f1b is `f1bv`") {
                    expect(data.string(forKeyPath: "f1.f1b")).to(equal("f1bv"))
                }

                it("f1.f1c is `f1cv`") {
                    expect(data.string(forKeyPath: "f1.f1c")).to(equal("f1cv"))
                }

                it("f2 is `f2v`") {
                    expect(data.string(forKeyPath: "f2")).to(equal("f2v"))
                }
            }
        }
        
        describe("a merging recursive") {
            context("no conflict") {
                let base: [String: JSONValue] = ["f1": "f1v"].mapValues { $0.jsonValue }
                var data: [String: JSONValue]!

                beforeSuite {
                    let ext: [String: JSONValue] = ["f2": "f2v"].mapValues { $0.jsonValue }
                    data = base.mergingRecursive(ext)
                }

                it("f1 is `f1v`") {
                    expect(data.string(forKeyPath: "f1")).to(equal("f1v"))
                }

                it("f2 is `f2v`") {
                    expect(data.string(forKeyPath: "f2")).to(equal("f2v"))
                }
                
                it("base f2 is nil") {
                    expect(base.string(forKeyPath: "f2")).to(beNil())
                }
            }

            context("conflict premitive value") {
                let base: [String: JSONValue] = ["f1": "f1v1"].mapValues { $0.jsonValue }
                var data: [String: JSONValue]!

                beforeSuite {
                    let ext: [String: JSONValue] = ["f1": "f1v2"].mapValues { $0.jsonValue }
                    data = base.mergingRecursive(ext)
                }

                it("f1 is `f1v2`") {
                    expect(data.string(forKeyPath: "f1")).to(equal("f1v2"))
                }
                
                it("base.f1 is `f1v1`") {
                    expect(base.string(forKeyPath: "f1")).to(equal("f1v1"))
                }
            }

            context("conflict dictionary value") {
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
                var data: [String: JSONValue]!

                beforeSuite {
                    let ext: [String: JSONConvertible] = [
                        "f1": [
                            "f1a": [
                                "f1a1": "f1a1v2",
                                "f1a3": "f1a3v"
                            ],
                            "f1c": "f1cv"
                        ],
                        "f2": "f2v"
                    ]
                    data = base.mergingRecursive(ext.mapValues { $0.jsonValue })
                }

                it("f1.f1a.f1a1 is `f1a1v2`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a1")).to(equal("f1a1v2"))
                }

                it("f1.f1a.f1a2 is `f1a2v`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a2")).to(equal("f1a2v"))
                }

                it("f1.f1a.f1a3 is `f1a3v`") {
                    expect(data.string(forKeyPath: "f1.f1a.f1a3")).to(equal("f1a3v"))
                }

                it("f1.f1b is `f1bv`") {
                    expect(data.string(forKeyPath: "f1.f1b")).to(equal("f1bv"))
                }

                it("f1.f1c is `f1cv`") {
                    expect(data.string(forKeyPath: "f1.f1c")).to(equal("f1cv"))
                }

                it("f2 is `f2v`") {
                    expect(data.string(forKeyPath: "f2")).to(equal("f2v"))
                }
                
                it("base f1.f1a.f1a3 is nil") {
                    expect(base.string(forKeyPath: "f1.f1a.f1a3")).to(beNil())
                }
                
                it("base f1.f1c is nil") {
                    expect(base.string(forKeyPath: "f1.f1c")).to(beNil())
                }
                
                it("base f2.f2a is `f2av`") {
                    expect(base.string(forKeyPath: "f2.f2a")).to(equal("f2av"))
                }
            }
        }
    }
}
