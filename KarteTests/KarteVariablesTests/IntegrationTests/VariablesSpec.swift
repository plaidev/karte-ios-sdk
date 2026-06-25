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
import KarteUtilities
@testable import KarteCore
@testable import KarteVariables

// MARK: - Test Helper

/// テスト用: lastFetch 情報をシミュレート
private func simulateLastFetch(secondsAgo: TimeInterval, status: LastFetchStatus = .success) {
    UserDefaults.standard.set(Date(timeIntervalSinceNow: -secondsAgo), forKey: .lastFetchTime)
    UserDefaults.standard.set(status.rawValue, forKey: .lastFetchStatus)
}

class VariablesSpec: XCTestCase {
    private let configuration = Configuration { configuration in
        configuration.isSendInitializationEventEnabled = false
    }

    private lazy var fetchStubBuilder1 = StubBuilder(test: self, resource: .variables1).build()
    private lazy var fetchStubBuilder2 = StubBuilder(test: self, resource: .variables2).build()
    private lazy var fetchStubBuilder3 = StubBuilder(test: self, resource: .variables3).build()
    private lazy var fetchStubBuilder4 = StubBuilder(test: self, resource: .variables4).build()
    private lazy var otherStubBuilder = StubBuilder(test: self, resource: .empty).build()

    private func setupAndFetch(builder: @escaping Builder) {
        let module = StubActionModule(metadata: name, builder: builder)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Variables.fetch()
        module.wait()
        StubActionModule(metadata: name, builder: otherStubBuilder).wait()
    }

    // MARK: - message_ready event

    func testMessageReadyEventForControlGroup() {
        let module = StubActionModule(metadata: name, builder: fetchStubBuilder3)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Variables.fetch()
        module.wait()

        guard let event = StubActionModule(metadata: name, builder: otherStubBuilder).wait().event(.messageReady) else {
            XCTFail("messageReady event not found")
            return
        }
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "5e7dab7215bd5200119c9658", "campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "__5e7dab7215bd5200119c9658", "shorten_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_id"), "2020-03-27T14:25:37.151Z___5e7dab7215bd5200119c9658", "response_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_timestamp"), "2020-03-27T14:25:37.151Z", "response_timestamp")
        XCTAssertEqual(event.values.string(forKeyPath: "message.trigger.event_hashes"), "a001", "event_hashes")
        XCTAssertEqual(event.values.bool(forKeyPath: "no_action"), false, "no_action")
    }

    func testMessageReadyEventForNonControlGroup() {
        let module = StubActionModule(metadata: name, builder: fetchStubBuilder2)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Variables.fetch()
        module.wait()

        guard let event = StubActionModule(metadata: name, builder: otherStubBuilder).wait().event(.messageReady) else {
            XCTFail("messageReady event not found")
            return
        }
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "5b750a095db3aa091ed1f590", "campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "14kU", "shorten_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_id"), "2019-11-24T02:05:12.616Z_14kU", "response_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_timestamp"), "2019-11-24T02:05:12.616Z", "response_timestamp")
        XCTAssertEqual(event.values.string(forKeyPath: "message.trigger.event_hashes"), "a001", "event_hashes")
        XCTAssertEqual(event.values.bool(forKeyPath: "no_action"), false, "no_action")
    }

    func testMessageReadyEventForNoAction() {
        let module = StubActionModule(metadata: name, builder: fetchStubBuilder4)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Variables.fetch()
        module.wait()

        guard let event = StubActionModule(metadata: name, builder: otherStubBuilder).wait().event(.messageReady) else {
            XCTFail("messageReady event not found")
            return
        }
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "5b750a095db3aa091ed1f590", "campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "14kU", "shorten_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_id"), "2019-11-24T02:05:12.616Z_14kU", "response_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_timestamp"), "2019-11-24T02:05:12.616Z", "response_timestamp")
        XCTAssertEqual(event.values.string(forKeyPath: "message.trigger.event_hashes"), "a001", "event_hashes")
        XCTAssertEqual(event.values.bool(forKeyPath: "no_action"), true, "no_action")
        XCTAssertEqual(event.values.string(forKeyPath: "reason"), "foo", "reason")
    }

    // MARK: - fetch and retrieve

    func testGetAllKeys() {
        setupAndFetch(builder: fetchStubBuilder1)
        let keys = Variables.getAllKeys()
        XCTAssertTrue(keys.contains("var1"), "should contain var1")
        XCTAssertTrue(keys.contains("var2"), "should contain var2")
        XCTAssertTrue(keys.contains("var3"), "should contain var3")
        XCTAssertFalse(keys.contains("var4"), "should not contain var4")
        XCTAssertFalse(keys.contains("lastFetchTime"), "should not contain lastFetchTime")
        XCTAssertFalse(keys.contains("lastFetchStatus"), "should not contain lastFetchStatus")
    }

    func testClearAllCache() {
        setupAndFetch(builder: fetchStubBuilder1)
        Variables.clearCacheAll()
        XCTAssertNil(Variable(name: "var1").value, "var1 should be nil after clearAll")
        XCTAssertNil(Variable(name: "var2").value, "var2 should be nil after clearAll")
    }

    func testClearCacheByKey() {
        setupAndFetch(builder: fetchStubBuilder1)
        Variables.clearCache(forKey: "var1")
        XCTAssertNil(Variable(name: "var1").value, "var1 should be nil after clear")
        XCTAssertNotNil(Variable(name: "var2").value, "var2 should not be nil")
    }

    func testFilter() {
        setupAndFetch(builder: fetchStubBuilder1)

        let matched = Variables.filter { $0.hasPrefix("var") }.sorted { $0.name < $1.name }
        XCTAssertEqual(matched.count, 3, "matched count")
        XCTAssertEqual(matched[0].string, "変数1", "var1 value")
        XCTAssertEqual(matched[1].string, "変数2a", "var2 value")
        XCTAssertEqual(matched[2].string, "変数3a", "var3 value")

        let notMatched = Variables.filter { $0.hasPrefix("let") }
        XCTAssertEqual(notMatched.count, 0, "not matched count")
    }

    func testRetrieveVariable() {
        setupAndFetch(builder: fetchStubBuilder1)

        let var1 = Variable(name: "var1")
        XCTAssertNotNil(var1.value, "var1 should not be nil")
        XCTAssertEqual(var1.string, "変数1", "var1 value")

        let var2 = Variable(name: "var2")
        XCTAssertNotNil(var2.value, "var2 should not be nil")
        XCTAssertEqual(var2.string, "変数2a", "var2 value")

        let var3 = Variable(name: "var3")
        XCTAssertNotNil(var3.value, "var3 should not be nil")
        XCTAssertEqual(var3.string, "変数3a", "var3 value")
    }

    func testClearVariablesAfterSecondFetch() {
        setupAndFetch(builder: fetchStubBuilder1)
        setupAndFetch(builder: fetchStubBuilder2)

        XCTAssertNil(Variable(name: "var1").value, "var1 should be nil")
        XCTAssertNil(Variable(name: "var2").value, "var2 should be nil")

        let var3 = Variable(name: "var3")
        XCTAssertNotNil(var3.value, "var3 should not be nil")
        XCTAssertEqual(var3.string, "変数3b", "var3 value")

        let var4 = Variable(name: "var4")
        XCTAssertNotNil(var4.value, "var4 should not be nil")
        XCTAssertEqual(var4.string, "変数4", "var4 value")
    }

    func testOverrideVariables() {
        setupAndFetch(builder: fetchStubBuilder1)

        let module = StubActionModule(metadata: name, builder: fetchStubBuilder2)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Tracker.track(event: Event(.view(viewName: "foo", title: "bar", values: [:])))
        module.wait()
        StubActionModule(metadata: name, builder: otherStubBuilder).wait()

        let var1 = Variable(name: "var1")
        XCTAssertNotNil(var1.value, "var1 should not be nil")
        XCTAssertEqual(var1.string, "変数1", "var1 value")

        let var2 = Variable(name: "var2")
        XCTAssertNotNil(var2.value, "var2 should not be nil")
        XCTAssertEqual(var2.string, "変数2a", "var2 value")

        let var3 = Variable(name: "var3")
        XCTAssertNotNil(var3.value, "var3 should not be nil")
        XCTAssertEqual(var3.string, "変数3b", "var3 value")

        let var4 = Variable(name: "var4")
        XCTAssertNotNil(var4.value, "var4 should not be nil")
        XCTAssertEqual(var4.string, "変数4", "var4 value")
    }

    // MARK: - lastFetch information

    func testDefaultLastFetchInformation() {
        UserDefaults.standard.removeObject(forKey: .lastFetchStatus)
        UserDefaults.standard.removeObject(forKey: .lastFetchTime)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        XCTAssertEqual(Variables.lastFetchStatus, .nofetchYet, "lastFetchStatus")
        XCTAssertNil(Variables.lastFetchTime, "lastFetchTime should be nil")
        XCTAssertFalse(Variables.hasSuccessfulLastFetch(inSeconds: 100), "hasSuccessfulLastFetch")
    }

    func testUpdateLastFetchInformation() {
        setupAndFetch(builder: fetchStubBuilder1)
        setupAndFetch(builder: fetchStubBuilder2)

        XCTAssertNotNil(Variables.lastFetchTime, "lastFetchTime should not be nil")
        XCTAssertEqual(Variables.lastFetchStatus, .success, "lastFetchStatus")
        XCTAssertTrue(Variables.hasSuccessfulLastFetch(inSeconds: 1), "hasSuccessfulLastFetch(1s)")
        XCTAssertTrue(Variables.hasSuccessfulLastFetch(inSeconds: 60), "hasSuccessfulLastFetch(60s)")
    }

    func testHasSuccessfulLastFetchReturnsFalseWhenExpired() {
        setupAndFetch(builder: fetchStubBuilder1)
        setupAndFetch(builder: fetchStubBuilder2)

        simulateLastFetch(secondsAgo: 2)
        XCTAssertFalse(Variables.hasSuccessfulLastFetch(inSeconds: 1), "should return false when expired")
    }

    func testHasSuccessfulLastFetchReturnsFalseForMinusValue() {
        setupAndFetch(builder: fetchStubBuilder1)
        setupAndFetch(builder: fetchStubBuilder2)

        XCTAssertFalse(Variables.hasSuccessfulLastFetch(inSeconds: -60), "should return false for minus value")
    }

    // MARK: - fetchCompletion

    func testFetchCompletionWhenOnline() {
        let module = StubActionModule(metadata: name, builder: fetchStubBuilder1)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        var result: Bool!
        Variables.fetch { isSuccess in
            result = isSuccess
        }
        module.wait()
        StubActionModule(metadata: name, builder: otherStubBuilder).wait()

        XCTAssertTrue(result, "result should be true when online")
    }

    func testFetchCompletionWhenOffline() {
        Resolver.root = Resolver.submock
        Resolver.root.register(Bool.self, name: "isReachable") {
            false
        }
        defer { Resolver.root = Resolver.mock }

        let module = StubActionModule(metadata: name, builder: fetchStubBuilder1)
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        var result: Bool!
        Variables.fetch { isSuccess in
            result = isSuccess
            module.finish()
        }
        module.wait()

        XCTAssertFalse(result, "result should be false when offline")
        XCTAssertNotNil(Variables.lastFetchTime, "lastFetchTime should not be nil")
        XCTAssertEqual(Variables.lastFetchStatus, .failure, "lastFetchStatus")
        XCTAssertFalse(Variables.hasSuccessfulLastFetch(inSeconds: 10), "hasSuccessfulLastFetch should be false")
    }
}
