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
@testable import KarteRemoteNotification

class PluginNativeAppIdentifyEventSpec: XCTestCase {

    func testPluginNativeAppIdentifyEventWithFCMTokenAndSubscribeTrue() throws {
        let event = Event(.pluginNativeAppIdentify(subscribe: true, fcmToken: "fcm_token"))

        XCTAssertEqual(event.eventName, .pluginNativeAppIdentify, "eventName")
        XCTAssertEqual(event.values.count, 2, "values count")
        XCTAssertEqual(event.values.string(forKey: "fcm_token"), "fcm_token", "values.fcm_token")
        let subscribe = try XCTUnwrap(event.values.bool(forKey: "subscribe"), "values.subscribe")
        XCTAssertTrue(subscribe, "values.subscribe")
    }

    func testPluginNativeAppIdentifyEventWithSubscribeFalse() throws {
        let event = Event(.pluginNativeAppIdentify(subscribe: false, fcmToken: nil))

        XCTAssertEqual(event.values.count, 1, "values count")
        let subscribe = try XCTUnwrap(event.values.bool(forKey: "subscribe"), "values.subscribe")
        XCTAssertFalse(subscribe, "values.subscribe")
    }
}
