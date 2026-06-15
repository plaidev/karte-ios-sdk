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
import KarteUtilities
@testable import KarteCore
@testable import KarteVariables

class TrackVariablesSpec: XCTestCase {
    private let configuration = Configuration { configuration in
        configuration.isSendInitializationEventEnabled = false
    }

    private let builder: Builder = { request in
        let response = TrackResponse(success: 1, status: 200, response: EMPTY_RESPONSE, error: nil)
        let data = try! createJSONEncoder().encode(response)
        return jsonData(data)(request)
    }

    func testTrackMessageOpen() {
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let variable = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: "t1", eventHash: "h1")
        Tracker.trackOpen(variables: [variable], values: ["foo": "bar"])

        guard let event = module.wait().event(.messageOpen) else {
            XCTFail("messageOpen event not found")
            return
        }
        XCTAssertEqual(event.eventName, EventName.messageOpen, "event name")
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "c1", "campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "s1", "shorten_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_id"), "t1_s1", "response_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_timestamp"), "t1", "response_timestamp")
        XCTAssertEqual(event.values.string(forKeyPath: "message.trigger.event_hashes"), "h1", "event_hashes")
        XCTAssertNil(event.values.bool(forKeyPath: "no_action"), "no_action should be nil")
        XCTAssertEqual(event.values.string(forKeyPath: "foo"), "bar", "custom value foo")
    }

    func testTrackMessageClick() {
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let variable = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: "t1", eventHash: "h1")
        Tracker.trackClick(variables: [variable], values: ["foo": "bar"])

        guard let event = module.wait().event(.messageClick) else {
            XCTFail("messageClick event not found")
            return
        }
        XCTAssertEqual(event.eventName, EventName.messageClick, "event name")
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "c1", "campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "s1", "shorten_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_id"), "t1_s1", "response_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.response_timestamp"), "t1", "response_timestamp")
        XCTAssertEqual(event.values.string(forKeyPath: "message.trigger.event_hashes"), "h1", "event_hashes")
        XCTAssertNil(event.values.bool(forKeyPath: "no_action"), "no_action should be nil")
        XCTAssertEqual(event.values.string(forKeyPath: "foo"), "bar", "custom value foo")
    }
}
