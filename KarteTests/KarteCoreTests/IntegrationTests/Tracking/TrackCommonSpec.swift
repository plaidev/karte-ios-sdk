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

class TrackCommonSpec: XCTestCase {

    func testTrackCommon() {
        let idfa = IDFA()
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
            configuration.idfaDelegate = idfa
        }
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let event = Event(eventName: EventName("test"))
        Tracker.track(event: event)

        guard let body = module.wait().body(EventName("test")) else {
            XCTFail("body for 'test' event should not be nil")
            return
        }

        // keys
        XCTAssertEqual(body.keys.visitorId, "dummy_visitor_id", "keys.visitor_id")
        XCTAssertEqual(body.keys.pvId.identifier, "dummy_pv_id", "keys.pv_id")
        XCTAssertEqual(body.keys.originalPvId.identifier, "dummy_original_pv_id", "keys.original_pv_id")

        // app_info
        XCTAssertEqual(body.appInfo.versionName, "1.0.0", "app_info.version_name")
        XCTAssertEqual(body.appInfo.versionCode, "1", "app_info.version_code")
        XCTAssertEqual(body.appInfo.karteSdkVersion, "1.0.0", "app_info.karte_sdk_version")
        XCTAssertEqual(body.appInfo.moduleInfo["core"], "2.0.0", "app_info.module_info.core")
        XCTAssertEqual(body.appInfo.moduleInfo["in_app_messaging"], "2.0.0", "app_info.module_info.in_app_messaging")

        // app_info.system_info
        XCTAssertEqual(body.appInfo.systemInfo.os, "iOS", "app_info.system_info.os")
        XCTAssertEqual(body.appInfo.systemInfo.osVersion, "13.0", "app_info.system_info.os_version")
        XCTAssertEqual(body.appInfo.systemInfo.device, "iPhone", "app_info.system_info.device")
        XCTAssertEqual(body.appInfo.systemInfo.model, "iPhone10,3", "app_info.system_info.model")
        XCTAssertEqual(body.appInfo.systemInfo.bundleId, "io.karte", "app_info.system_info.bundle_id")
        XCTAssertEqual(body.appInfo.systemInfo.language, "ja-JP", "app_info.system_info.language")
        XCTAssertEqual(body.appInfo.systemInfo.idfv, "dummy_idfv", "app_info.system_info.idfv")
        XCTAssertEqual(body.appInfo.systemInfo.idfa, "dummy_idfa", "app_info.system_info.idfa")

        // app_info.system_info.screen
        XCTAssertEqual(body.appInfo.systemInfo.screen.width, 375, "app_info.system_info.screen.width")
        XCTAssertEqual(body.appInfo.systemInfo.screen.height, 812, "app_info.system_info.screen.height")
    }
}
