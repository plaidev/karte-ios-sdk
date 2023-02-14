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

final class JSONConvertibleSpec: QuickSpec {
    override func spec() {
        describe("a merge recursive") {
            context("no conflict") {
                var data: [String: JSONConvertible] = ["f1": "f1v"]

                beforeSuite {
                    let ext: [String: JSONConvertible] = ["f2": "f2v"]
                    data.mergeRecursive(ext)
                }

                it("f1 is `f1v`") {
                    expect(data["f1"] as? String).to(equal("f1v"))
                }

                it("f2 is `f2v`") {
                    expect(data["f2"] as? String).to(equal("f2v"))
                }
            }

            context("conflict premitive value") {
                var data: [String: JSONConvertible] = ["f1": "f1v1"]

                beforeSuite {
                    let ext: [String: JSONConvertible] = ["f1": "f1v2"]
                    data.mergeRecursive(ext)
                }

                it("f1 is `f1v2`") {
                    expect(data["f1"] as? String).to(equal("f1v2"))
                }
            }

            context("conflict premitive value") {
                var data: [String: JSONConvertible] = ["f1": "f1v1"]

                beforeSuite {
                    let ext: [String: JSONConvertible] = ["f1": "f1v2"]
                    data.mergeRecursive(ext)
                }

                it("f1 is `f1v2`") {
                    expect(data["f1"] as? String).to(equal("f1v2"))
                }
            }

            
            context("conflict dictionary value") {
                var data: [String: JSONConvertible] = [
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
                    data.mergeRecursive(ext)
                }

                it("f1.f1a.f1a1 is `f1a1v2`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a1")).to(equal("f1a1v2"))
                }

                it("f1.f1a.f1a2 is `f1a2v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a2")).to(equal("f1a2v"))
                }

                it("f1.f1a.f1a3 is `f1a3v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a3")).to(equal("f1a3v"))
                }

                it("f1.f1b is `f1bv`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1b")).to(equal("f1bv"))
                }

                it("f1.f1c is `f1cv`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1c")).to(equal("f1cv"))
                }

                it("f2 is `f2v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f2")).to(equal("f2v"))
                }
            }
        }
        
        describe("a merging recursive") {
            context("no conflict") {
                let base: [String: JSONConvertible] = ["f1": "f1v"]
                var data: [String: JSONConvertible]!

                beforeSuite {
                    let ext: [String: JSONConvertible] = ["f2": "f2v"]
                    data = base.mergingRecursive(ext)
                }

                it("f1 is `f1v`") {
                    expect(data["f1"] as? String).to(equal("f1v"))
                }

                it("f2 is `f2v`") {
                    expect(data["f2"] as? String).to(equal("f2v"))
                }
                
                it("base f2 is nil") {
                    expect(base["f2"] as? String).to(beNil())
                }
            }

            context("conflict premitive value") {
                let base: [String: JSONConvertible] = ["f1": "f1v1"]
                var data: [String: JSONConvertible]!

                beforeSuite {
                    let ext: [String: JSONConvertible] = ["f1": "f1v2"]
                    data = base.mergingRecursive(ext)
                }

                it("f1 is `f1v2`") {
                    expect(data["f1"] as? String).to(equal("f1v2"))
                }
                
                it("base.f1 is `f1v1`") {
                    expect(base["f1"] as? String).to(equal("f1v1"))
                }
            }

            context("conflict dictionary value") {
                let base: [String: JSONConvertible] = [
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
                var data: [String: JSONConvertible]!

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
                    data = base.mergingRecursive(ext)
                }

                it("f1.f1a.f1a1 is `f1a1v2`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a1")).to(equal("f1a1v2"))
                }

                it("f1.f1a.f1a2 is `f1a2v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a2")).to(equal("f1a2v"))
                }

                it("f1.f1a.f1a3 is `f1a3v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a3")).to(equal("f1a3v"))
                }

                it("f1.f1b is `f1bv`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1b")).to(equal("f1bv"))
                }

                it("f1.f1c is `f1cv`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1c")).to(equal("f1cv"))
                }

                it("f2 is `f2v`") {
                    let v = data.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f2")).to(equal("f2v"))
                }
                
                it("base f1.f1a.f1a3 is nil") {
                    let v = base.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1a.f1a3")).to(beNil())
                }
                
                it("base f1.f1c is nil") {
                    let v = base.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f1.f1c")).to(beNil())
                }
                
                it("base f2.f2a is `f2av`") {
                    let v = base.mapValues { $0.jsonValue }
                    expect(v.string(forKeyPath: "f2.f2a")).to(equal("f2av"))
                }
            }
        }
    }
}
