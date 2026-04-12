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

class EventNameSpec: XCTestCase {

    func testIsInitializationEvent() {
        XCTAssertTrue(EventName.nativeAppInstall.isInitializationEvent, "nativeAppInstall")
        XCTAssertTrue(EventName.nativeAppUpdate.isInitializationEvent, "nativeAppUpdate")
        XCTAssertTrue(EventName.nativeAppOpen.isInitializationEvent, "nativeAppOpen")
        XCTAssertTrue(EventName.nativeAppCrashed.isInitializationEvent, "nativeAppCrashed")
        XCTAssertFalse(EventName("foo").isInitializationEvent, "foo should not be initialization event")
    }

    func testIsUserDefinedEvent() {
        XCTAssertFalse(EventName.view.isUserDefinedEvent, "view")
        XCTAssertFalse(EventName.identify.isUserDefinedEvent, "identify")
        XCTAssertFalse(EventName.attribute.isUserDefinedEvent, "attribute")
        XCTAssertFalse(EventName.nativeAppInstall.isUserDefinedEvent, "nativeAppInstall")
        XCTAssertFalse(EventName.nativeAppUpdate.isUserDefinedEvent, "nativeAppUpdate")
        XCTAssertFalse(EventName.nativeAppOpen.isUserDefinedEvent, "nativeAppOpen")
        XCTAssertFalse(EventName.nativeAppForeground.isUserDefinedEvent, "nativeAppForeground")
        XCTAssertFalse(EventName.nativeAppBackground.isUserDefinedEvent, "nativeAppBackground")
        XCTAssertFalse(EventName.nativeAppCrashed.isUserDefinedEvent, "nativeAppCrashed")
        XCTAssertFalse(EventName.nativeAppRenewVisitorId.isUserDefinedEvent, "nativeAppRenewVisitorId")
        XCTAssertFalse(EventName.nativeFindMyself.isUserDefinedEvent, "nativeFindMyself")
        XCTAssertFalse(EventName.deepLinkAppOpen.isUserDefinedEvent, "deepLinkAppOpen")
        XCTAssertFalse(EventName.messageReady.isUserDefinedEvent, "messageReady")
        XCTAssertFalse(EventName.messageOpen.isUserDefinedEvent, "messageOpen")
        XCTAssertFalse(EventName.messageClose.isUserDefinedEvent, "messageClose")
        XCTAssertFalse(EventName.messageClick.isUserDefinedEvent, "messageClick")
        XCTAssertFalse(EventName.messageSuppressed.isUserDefinedEvent, "messageSuppressed")
        XCTAssertFalse(EventName.massPushClick.isUserDefinedEvent, "massPushClick")
        XCTAssertFalse(EventName.pluginNativeAppIdentify.isUserDefinedEvent, "pluginNativeAppIdentify")
        XCTAssertFalse(EventName.fetchVariables.isUserDefinedEvent, "fetchVariables")
        XCTAssertTrue(EventName("foo").isUserDefinedEvent, "foo should be user defined event")
    }

    func testEventNameRawValues() {
        XCTAssertEqual(EventName.view.rawValue, "view", "view")
        XCTAssertEqual(EventName.identify.rawValue, "identify", "identify")
        XCTAssertEqual(EventName.attribute.rawValue, "attribute", "attribute")
        XCTAssertEqual(EventName.nativeAppInstall.rawValue, "native_app_install", "nativeAppInstall")
        XCTAssertEqual(EventName.nativeAppUpdate.rawValue, "native_app_update", "nativeAppUpdate")
        XCTAssertEqual(EventName.nativeAppOpen.rawValue, "native_app_open", "nativeAppOpen")
        XCTAssertEqual(EventName.nativeAppForeground.rawValue, "native_app_foreground", "nativeAppForeground")
        XCTAssertEqual(EventName.nativeAppBackground.rawValue, "native_app_background", "nativeAppBackground")
        XCTAssertEqual(EventName.nativeAppCrashed.rawValue, "native_app_crashed", "nativeAppCrashed")
        XCTAssertEqual(EventName.nativeAppRenewVisitorId.rawValue, "native_app_renew_visitor_id", "nativeAppRenewVisitorId")
        XCTAssertEqual(EventName.deepLinkAppOpen.rawValue, "deep_link_app_open", "deepLinkAppOpen")
        XCTAssertEqual(EventName.messageReady.rawValue, "_message_ready", "messageReady")
        XCTAssertEqual(EventName.messageOpen.rawValue, "message_open", "messageOpen")
        XCTAssertEqual(EventName.messageClose.rawValue, "message_close", "messageClose")
        XCTAssertEqual(EventName.messageClick.rawValue, "message_click", "messageClick")
        XCTAssertEqual(EventName.massPushClick.rawValue, "mass_push_click", "massPushClick")
        XCTAssertEqual(EventName.pluginNativeAppIdentify.rawValue, "plugin_native_app_identify", "pluginNativeAppIdentify")
        XCTAssertEqual(EventName.fetchVariables.rawValue, "_fetch_variables", "fetchVariables")
    }

    func testEventNameEquality() {
        XCTAssertEqual(EventName.nativeAppInstall, EventName.nativeAppInstall, "same event name should be equal")
        XCTAssertNotEqual(EventName.nativeAppInstall, EventName.nativeAppUpdate, "different event names should not be equal")
    }

    func testEventNameEncode() {
        let data = try! JSONEncoder().encode(EventName.nativeAppInstall)
        let eventName = String(data: data, encoding: .utf8)!
        XCTAssertEqual(eventName, "\"\(EventName.nativeAppInstall.rawValue)\"", "encoded value")
    }

    func testEventNameDecode() {
        let data = "\"\(EventName.nativeAppInstall.rawValue)\"".data(using: .utf8)!
        let eventName = try! JSONDecoder().decode(EventName.self, from: data)
        XCTAssertEqual(eventName, EventName.nativeAppInstall, "decoded value")
    }
}
