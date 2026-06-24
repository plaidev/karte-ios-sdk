//
//  Copyright 2021 PLAID, Inc.
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

class RemoteNotificationSetupSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        RemoteNotification.isEnabledAutoMeasurement = true
    }

    func testSetupWithDefaultConfiguration_RemoteNotificationProxyIsEnabled() {
        guard let configuration = Configuration.default else {
            XCTFail("Configuration.default should not be nil")
            return
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        XCTAssertTrue(RemoteNotificationProxy.shared.isEnabled, "RemoteNotificationProxy should be enabled")
    }

    func testSetupWithDefaultLibraryConfiguration_RemoteNotificationProxyIsEnabled() {
        guard let configuration = Configuration.default else {
            XCTFail("Configuration.default should not be nil")
            return
        }
        configuration.libraryConfigurations = [RemoteNotificationConfiguration()]
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        XCTAssertTrue(RemoteNotificationProxy.shared.isEnabled, "RemoteNotificationProxy should be enabled")
    }

    func testSetupWithCustomLibraryConfiguration_RemoteNotificationProxyIsDisabled() {
        guard let configuration = Configuration.default else {
            XCTFail("Configuration.default should not be nil")
            return
        }
        let remoteNotificationConfiguration = RemoteNotificationConfiguration()
        remoteNotificationConfiguration.isEnabledAutoMeasurement = false
        configuration.libraryConfigurations = [remoteNotificationConfiguration]
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        XCTAssertFalse(RemoteNotificationProxy.shared.isEnabled, "RemoteNotificationProxy should be disabled")
    }

    func testSetupWithDeprecatedStaticConfig_RemoteNotificationProxyIsDisabled() {
        RemoteNotification.isEnabledAutoMeasurement = false
        KarteApp.setup(appKey: APP_KEY)

        XCTAssertFalse(RemoteNotificationProxy.shared.isEnabled, "RemoteNotificationProxy should be disabled")
    }
}
