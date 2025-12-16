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

import Quick
import Nimble
@testable import KarteCore
@testable import KarteVariables

class VariableSpec: QuickSpec {
    
    override class func spec() {
        describe("a variable") {
            context("variable is not defined") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "name")
                }
                
                it("name is `name`") {
                    expect(variable.name).to(equal("name"))
                }
                
                it("campaign_id is nil") {
                    expect(variable.campaignId).to(beNil())
                }
                
                it("shorten_id is nil") {
                    expect(variable.shortenId).to(beNil())
                }
                
                it("value is nil") {
                    expect(variable.value).to(beNil())
                }
                
                it("isDefined is false") {
                    expect(variable.isDefined).to(beFalse())
                }
                
                it("timestamp is nil") {
                    expect(variable.timestamp).to(beNil())
                }
                
                it("eventHash is nil") {
                    expect(variable.eventHash).to(beNil())
                }
            }
            
            context("variable is defined") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "name", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: "timestamp", eventHash: "eventHash")
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }

                it("name is `name`") {
                    expect(variable.name).to(equal("name"))
                }
                
                it("campaign_id is `campaign_id`") {
                    expect(variable.campaignId).to(equal("campaign_id"))
                }
                
                it("shorten_id is `shorten_id`") {
                    expect(variable.shortenId).to(equal("shorten_id"))
                }
                
                it("value is `foo`") {
                    expect(variable.value).to(equal("foo"))
                }
                
                it("isDefined is true") {
                    expect(variable.isDefined).to(beTrue())
                }
                
                it("timestamp is `timestamp`") {
                    expect(variable.timestamp).to(equal("timestamp"))
                }
                
                it("eventHash is `eventHash`") {
                    expect(variable.eventHash).to(equal("eventHash"))
                }
            }
            
            context("basic parameters") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }

                it("name is `value`") {
                    let variable = Variable(name: "value")
                    expect(variable.name).to(equal("value"))
                }
                
                it("campaignId is `campaign_id`") {
                    let variable = Variable(name: "value")
                    expect(variable.campaignId).to(equal("campaign_id"))
                }
                
                it("shortenId is `shorten_id`") {
                    let variable = Variable(name: "value")
                    expect(variable.shortenId).to(equal("shorten_id"))
                }
            }
            
            context("value is `foo`") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `foo`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("foo"))
                    }
                }
                
                context("its string with default") {
                    it("value is `foo`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "bar")).to(equal("foo"))
                    }
                }
                
                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(100))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(100.1))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).toNot(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is 0") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "0", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("0"))
                    }
                }
                
                context("its string with default") {
                    it("value is `0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "1")).to(equal("0"))
                    }
                }

                context("its integer with default") {
                    it("value is 0") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(0))
                    }
                }
                
                context("its double with default") {
                    it("value is 0") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(0))
                    }
                }
                
                context("its bool with default") {
                    it("value is false") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).to(beFalse())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is 1") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "1", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("1"))
                    }
                }
                
                context("its string with default") {
                    it("value is `1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal("1"))
                    }
                }

                context("its integer with default") {
                    it("value is 1") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(1))
                    }
                }
                
                context("its double with default") {
                    it("value is 1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(1))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is MAX_INT") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: String(Int.max), timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `MAX_INT`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal(String(Int.max)))
                    }
                }
                
                context("its string with default") {
                    it("value is `MAX_INT`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal(String(Int.max)))
                    }
                }

                context("its integer with default") {
                    it("value is MAX_INT") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(Int.max))
                    }
                }
                
                context("its double with default") {
                    it("value is MAX_INT") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(Double(Int.max)))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is MAX_INT + 1") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "9223372036854775808", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `MAX_INT + 1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("9223372036854775808"))
                    }
                }
                
                context("its string with default") {
                    it("value is `MAX_INT + 1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal("9223372036854775808"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(Int.max))
                    }
                }
                
                context("its double with default") {
                    it("value is MAX_INT + 1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(Double(Int.max) + 1))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is MIN_INT") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: String(Int.min), timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `MIN_INT`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal(String(Int.min)))
                    }
                }
                
                context("its string with default") {
                    it("value is `MIN_INT`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal(String(Int.min)))
                    }
                }

                context("its integer with default") {
                    it("value is MIN_INT") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(Int.min))
                    }
                }
                
                context("its double with default") {
                    it("value is MIN_INT") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(Double(Int.min)))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is MIN_INT - 1") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "-9223372036854775809", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `MIN_INT - 1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("-9223372036854775809"))
                    }
                }
                
                context("its string with default") {
                    it("value is `MIN_INT - 1`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal("-9223372036854775809"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(Int.min))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(Double(Int.min) - 1))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is 0.0") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "0.0", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `0.0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("0.0"))
                    }
                }
                
                context("its string with default") {
                    it("value is `0.0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal("0.0"))
                    }
                }

                context("its integer with default") {
                    it("value is 0") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(0))
                    }
                }
                
                context("its double with default") {
                    it("value is 0.0") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(0.0))
                    }
                }
                
                context("its bool with default") {
                    it("value is false") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).to(beFalse())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is 1.0") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "1.0", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `1.0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("1.0"))
                    }
                }
                
                context("its string with default") {
                    it("value is `1.0`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "0")).to(equal("1.0"))
                    }
                }

                context("its integer with default") {
                    it("value is 1") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(1))
                    }
                }
                
                context("its double with default") {
                    it("value is 1.0") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(1.0))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is true") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "true", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `true`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("true"))
                    }
                }
                
                context("its string with default") {
                    it("value is `true`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "false")).to(equal("true"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(100))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(100.1))
                    }
                }
                
                context("its bool with default") {
                    it("value is true") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: false)).to(beTrue())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is false") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "false", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `false`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("false"))
                    }
                }
                
                context("its string with default") {
                    it("value is `false`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "true")).to(equal("false"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(100))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(100.1))
                    }
                }
                
                context("its bool with default") {
                    it("value is false") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).to(beFalse())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is [\"foo\", \"bar\"]") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "[\"foo\", \"bar\"]", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `[\"foo\", \"bar\"]`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("[\"foo\", \"bar\"]"))
                    }
                }
                
                context("its string with default") {
                    it("value is `[\"foo\", \"bar\"]`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "[]")).to(equal("[\"foo\", \"bar\"]"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(100))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(100.1))
                    }
                }
                
                context("its bool with default") {
                    it("value is false") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).to(beFalse())
                    }
                }
                
                context("its array") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["bar", "foo"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary).to(beNil())
                    }
                }
                
                context("its dictionary with default") {
                    it("value is [\"foo\": \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["foo": "bar"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
            
            context("value is {\"foo\": \"bar\"}") {
                var variable: Variable!
                
                beforeEach {
                    variable = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "{\"foo\": \"bar\"}", timestamp: nil, eventHash: nil)
                    variable.save()
                }
                
                afterEach {
                    variable.clear()
                }
                
                context("its string") {
                    it("value is `{\"foo\": \"bar\"}`") {
                        let variable = Variable(name: "value")
                        expect(variable.string).to(equal("{\"foo\": \"bar\"}"))
                    }
                }
                
                context("its string with default") {
                    it("value is `{\"foo\": \"bar\"}`") {
                        let variable = Variable(name: "value")
                        expect(variable.string(default: "{}")).to(equal("{\"foo\": \"bar\"}"))
                    }
                }

                context("its integer with default") {
                    it("value is 100") {
                        let variable = Variable(name: "value")
                        expect(variable.integer(default: 100)).to(equal(100))
                    }
                }
                
                context("its double with default") {
                    it("value is 100.1") {
                        let variable = Variable(name: "value")
                        expect(variable.double(default: 100.1)).to(equal(100.1))
                    }
                }
                
                context("its bool with default") {
                    it("value is false") {
                        let variable = Variable(name: "value")
                        expect(variable.bool(default: true)).to(beFalse())
                    }
                }
                
                context("its array") {
                    it("value is nil") {
                        let variable = Variable(name: "value")
                        expect(variable.array).to(beNil())
                    }
                }
                
                context("its array with default") {
                    it("value is [\"foo\", \"bar\"]") {
                        let variable = Variable(name: "value")
                        expect(variable.array(default: ["foo", "bar"]) as? [String]).to(equal(["foo", "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is {\"foo\": \"bar\"}") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
                
                context("its dictionary with default") {
                    it("value is {\"foo\": \"bar\"}") {
                        let variable = Variable(name: "value")
                        expect(variable.dictionary(default: ["bar": "foo"]) as? [String: String]).to(equal(["foo": "bar"]))
                    }
                }
            }
        }
        
        describe("backward compatibility check") {
            var variable: Variable!
            
            beforeSuite {
                let v = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: nil, eventHash: nil)
                Variables.bulkSave(variables: [v])
                
                variable = Variables.variable(forKey: "foo")
            }
            
            it("value is `bar`") {
                expect(variable.string).to(equal("bar"))
            }
            
            it("campaignId is `c1`") {
                expect(variable.campaignId).to(equal("c1"))
            }
            
            it("shortenId is `s1`") {
                expect(variable.shortenId).to(equal("s1"))
            }
            
            it("timestamp is nil") {
                expect(variable.timestamp).to(beNil())
            }
            
            it("eventHash is nil") {
                expect(variable.eventHash).to(beNil())
            }
        }
    }
}
