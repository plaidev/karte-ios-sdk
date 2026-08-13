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
@testable import KarteRemoteNotification

class FCMTokenRegistrarSpec: XCTestCase {
    private var builder: Builder!

    override func setUp() {
        super.setUp()

        builder = { request in
            let response = TrackResponse(success: 1, status: 200, response: EMPTY_RESPONSE, error: nil)
            let data = try! createJSONEncoder().encode(response)
            return jsonData(data)(request)
        }

        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
    }

    // MARK: - first time

    func testFirstTimeRegisterFCMToken() throws {
        let module = StubActionModule(metadata: name, builder: builder)

        let provider = NotificationSettingsProviderMock()
        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { true }

        let registrar = FCMTokenRegistrar(provider)
        registrar.registerFCMToken()

        guard let event = module.wait().event(.pluginNativeAppIdentify) else {
            XCTFail("event should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .pluginNativeAppIdentify, "event name is plugin_native_app_identify")
        XCTAssertEqual(event.values.string(forKey: field(.fcmToken)), "dummy_fcm_token", "fcm_token is dummy_fcm_token")
        let subscribe = try XCTUnwrap(event.values.bool(forKey: field(.subscribe)), "subscribe should not be nil")
        XCTAssertTrue(subscribe, "subscribe is true")
    }

    // MARK: - second time (token updated)

    func testSecondTimeTokenUpdated() throws {
        let module1 = StubActionModule(
            metadata: "FCMTokenRegistrarSpec_testSecondTimeTokenUpdated_1",
            builder: builder
        )

        let provider = NotificationSettingsProviderMock()
        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { true }

        let registrar = FCMTokenRegistrar(provider)
        registrar.registerFCMToken()

        module1.wait()

        let module2 = StubActionModule(
            metadata: "FCMTokenRegistrarSpec_testSecondTimeTokenUpdated_2",
            builder: builder
        )

        provider.fcmTokenResolver = { "dummy_fcm_token_2" }
        provider.availabilityResolver = { true }
        registrar.registerFCMToken()

        guard let event = module2.wait().event(.pluginNativeAppIdentify) else {
            XCTFail("event should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .pluginNativeAppIdentify, "event name is plugin_native_app_identify")
        XCTAssertEqual(event.values.string(forKey: field(.fcmToken)), "dummy_fcm_token_2", "fcm_token is dummy_fcm_token_2")
        let subscribe = try XCTUnwrap(event.values.bool(forKey: field(.subscribe)), "subscribe should not be nil")
        XCTAssertTrue(subscribe, "subscribe is true")
    }

    // MARK: - second time (subscribe updated)

    func testSecondTimeSubscribeUpdated() throws {
        let module1 = StubActionModule(metadata: name, builder: builder)

        let provider = NotificationSettingsProviderMock()
        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { true }

        let registrar = FCMTokenRegistrar(provider)
        registrar.registerFCMToken()

        module1.wait()

        let module2 = StubActionModule(metadata: name, builder: builder)

        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { false }
        registrar.registerFCMToken()

        guard let event = module2.wait().event(.pluginNativeAppIdentify) else {
            XCTFail("event should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .pluginNativeAppIdentify, "event name is plugin_native_app_identify")
        XCTAssertEqual(event.values.string(forKey: field(.fcmToken)), "dummy_fcm_token", "fcm_token is dummy_fcm_token")
        let subscribe = try XCTUnwrap(event.values.bool(forKey: field(.subscribe)), "subscribe should not be nil")
        XCTAssertFalse(subscribe, "subscribe is false")
    }

    // MARK: - second time (same settings)

    func testSecondTimeSameSettings() {
        let module1 = StubActionModule(metadata: name, builder: builder)

        let provider = NotificationSettingsProviderMock()
        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { true }

        let registrar = FCMTokenRegistrar(provider)
        registrar.registerFCMToken()

        module1.wait()

        let module2 = StubActionModule(metadata: name, builder: builder)

        provider.fcmTokenResolver = { "dummy_fcm_token" }
        provider.availabilityResolver = { true }
        registrar.registerFCMToken()

        let event = module2.verify().event(.pluginNativeAppIdentify)

        XCTAssertNil(event, "event should be nil when settings unchanged")
    }
}
