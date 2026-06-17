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
@testable import KarteVariables

class VariableSpec: XCTestCase {

    // MARK: - variable is not defined

    func testVariableNotDefined() {
        let variable = Variable(name: "name")
        XCTAssertEqual(variable.name, "name", "name")
        XCTAssertNil(variable.campaignId, "campaignId should be nil")
        XCTAssertNil(variable.shortenId, "shortenId should be nil")
        XCTAssertNil(variable.value, "value should be nil")
        XCTAssertFalse(variable.isDefined, "isDefined should be false")
        XCTAssertNil(variable.timestamp, "timestamp should be nil")
        XCTAssertNil(variable.eventHash, "eventHash should be nil")
    }

    // MARK: - variable is defined

    func testVariableDefined() {
        let variable = Variable(name: "name", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: "timestamp", eventHash: "eventHash")
        variable.save()
        defer { variable.clear() }

        XCTAssertEqual(variable.name, "name", "name")
        XCTAssertEqual(variable.campaignId, "campaign_id", "campaignId")
        XCTAssertEqual(variable.shortenId, "shorten_id", "shortenId")
        XCTAssertEqual(variable.value, "foo", "value")
        XCTAssertTrue(variable.isDefined, "isDefined should be true")
        XCTAssertEqual(variable.timestamp, "timestamp", "timestamp")
        XCTAssertEqual(variable.eventHash, "eventHash", "eventHash")
    }

    // MARK: - basic parameters

    func testBasicParametersFromCache() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let variable = Variable(name: "value")
        XCTAssertEqual(variable.name, "value", "name")
        XCTAssertEqual(variable.campaignId, "campaign_id", "campaignId")
        XCTAssertEqual(variable.shortenId, "shorten_id", "shortenId")
    }

    // MARK: - value is "foo"

    func testValueFoo() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "foo", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "foo", "string")
        XCTAssertEqual(v.string(default: "bar"), "foo", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 100, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 100.1, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "0"

    func testValue0() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "0", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "0", "string")
        XCTAssertEqual(v.string(default: "1"), "0", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 0, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 0, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "1"

    func testValue1() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "1", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "1", "string")
        XCTAssertEqual(v.string(default: "0"), "1", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 1, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 1, "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is MAX_INT

    func testValueMaxInt() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: String(Int.max), timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, String(Int.max), "string")
        XCTAssertEqual(v.string(default: "0"), String(Int.max), "string(default:)")
        XCTAssertEqual(v.integer(default: 100), Int.max, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), Double(Int.max), "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is MAX_INT + 1

    func testValueMaxIntPlus1() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "9223372036854775808", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "9223372036854775808", "string")
        XCTAssertEqual(v.string(default: "0"), "9223372036854775808", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), Int.max, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), Double(Int.max) + 1, "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is MIN_INT

    func testValueMinInt() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: String(Int.min), timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, String(Int.min), "string")
        XCTAssertEqual(v.string(default: "0"), String(Int.min), "string(default:)")
        XCTAssertEqual(v.integer(default: 100), Int.min, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), Double(Int.min), "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is MIN_INT - 1

    func testValueMinIntMinus1() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "-9223372036854775809", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "-9223372036854775809", "string")
        XCTAssertEqual(v.string(default: "0"), "-9223372036854775809", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), Int.min, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), Double(Int.min) - 1, "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "0.0"

    func testValue0_0() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "0.0", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "0.0", "string")
        XCTAssertEqual(v.string(default: "0"), "0.0", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 0, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 0.0, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "1.0"

    func testValue1_0() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "1.0", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "1.0", "string")
        XCTAssertEqual(v.string(default: "0"), "1.0", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 1, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 1.0, "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "true"

    func testValueTrue() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "true", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "true", "string")
        XCTAssertEqual(v.string(default: "false"), "true", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 100, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 100.1, "double(default:)")
        XCTAssertTrue(v.bool(default: false), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is "false"

    func testValueFalse() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "false", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "false", "string")
        XCTAssertEqual(v.string(default: "true"), "false", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 100, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 100.1, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is array

    func testValueArray() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "[\"foo\", \"bar\"]", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "[\"foo\", \"bar\"]", "string")
        XCTAssertEqual(v.string(default: "[]"), "[\"foo\", \"bar\"]", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 100, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 100.1, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertEqual(v.array as? [String], ["foo", "bar"], "array")
        XCTAssertEqual(v.array(default: ["bar", "foo"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertNil(v.dictionary, "dictionary")
        XCTAssertEqual(v.dictionary(default: ["foo": "bar"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - value is dictionary

    func testValueDictionary() {
        let saved = Variable(name: "value", campaignId: "campaign_id", shortenId: "shorten_id", value: "{\"foo\": \"bar\"}", timestamp: nil, eventHash: nil)
        saved.save()
        defer { saved.clear() }

        let v = Variable(name: "value")
        XCTAssertEqual(v.string, "{\"foo\": \"bar\"}", "string")
        XCTAssertEqual(v.string(default: "{}"), "{\"foo\": \"bar\"}", "string(default:)")
        XCTAssertEqual(v.integer(default: 100), 100, "integer(default:)")
        XCTAssertEqual(v.double(default: 100.1), 100.1, "double(default:)")
        XCTAssertFalse(v.bool(default: true), "bool(default:)")
        XCTAssertNil(v.array, "array")
        XCTAssertEqual(v.array(default: ["foo", "bar"]) as? [String], ["foo", "bar"], "array(default:)")
        XCTAssertEqual(v.dictionary as? [String: String], ["foo": "bar"], "dictionary")
        XCTAssertEqual(v.dictionary(default: ["bar": "foo"]) as? [String: String], ["foo": "bar"], "dictionary(default:)")
    }

    // MARK: - backward compatibility

    func testBackwardCompatibility() {
        let v = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: nil, eventHash: nil)
        Variables.bulkSave(variables: [v])
        defer { v.clear() }

        let variable = Variables.variable(forKey: "foo")
        XCTAssertEqual(variable.string, "bar", "value")
        XCTAssertEqual(variable.campaignId, "c1", "campaignId")
        XCTAssertEqual(variable.shortenId, "s1", "shortenId")
        XCTAssertNil(variable.timestamp, "timestamp should be nil")
        XCTAssertNil(variable.eventHash, "eventHash should be nil")
    }
}
