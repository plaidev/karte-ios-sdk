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

class ConfigurationSpec: XCTestCase {

    func testDefaultConfiguration() {
        let configuration = KarteCore.Configuration.defaultConfiguration

        XCTAssertTrue(configuration.appKey.isEmpty, "appKey should be empty")
        XCTAssertTrue(configuration.apiKey.isEmpty, "apiKey should be empty")
        XCTAssertEqual(configuration.baseURL.absoluteString, "https://b.karte.io", "baseURL should be https://b.karte.io")
        XCTAssertEqual(configuration.dataLocation, "tw", "dataLocation should be tw")
        XCTAssertEqual(configuration.overlayBaseURL.absoluteString, "https://cf-native.karte.io", "overlayBaseURL should be https://cf-native.karte.io")
        XCTAssertFalse(configuration.isDryRun, "isDryRun should be false")
        XCTAssertFalse(configuration.isOptOut, "isOptOut should be false")
        XCTAssertTrue(configuration.isSendInitializationEventEnabled, "isSendInitializationEventEnabled should be true")
        XCTAssertTrue(configuration.libraryConfigurations.isEmpty, "libraryConfigurations should be empty")
        XCTAssertNil(configuration.idfaDelegate, "idfaDelegate should be nil")
    }

    func testCustomConfiguration() {
        let idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
        let configuration = KarteCore.Configuration { configuration in
            configuration.appKey = "dummy_application_key"
            configuration.apiKey = "dummy_api_key"
            configuration.baseURL = URL(string: "https://example.com")!
            configuration.dataLocation = "jp"
            configuration.overlayBaseURL = URL(string: "https://example.com")!
            configuration.isDryRun = true
            configuration.isOptOut = true
            configuration.isSendInitializationEventEnabled = false
            configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
            configuration.idfaDelegate = idfa
        }

        XCTAssertEqual(configuration.appKey, "dummy_application_key", "appKey should be dummy_application_key")
        XCTAssertEqual(configuration.apiKey, "dummy_api_key", "apiKey should be dummy_api_key")
        XCTAssertEqual(configuration.baseURL.absoluteString, "https://example.com", "baseURL should be https://example.com")
        XCTAssertEqual(configuration.dataLocation, "jp", "dataLocation should be jp")
        XCTAssertEqual(configuration.overlayBaseURL.absoluteString, "https://example.com", "overlayBaseURL should be https://example.com")
        XCTAssertTrue(configuration.isDryRun, "isDryRun should be true")
        XCTAssertTrue(configuration.isOptOut, "isOptOut should be true")
        XCTAssertFalse(configuration.isSendInitializationEventEnabled, "isSendInitializationEventEnabled should be false")
        XCTAssertFalse(configuration.libraryConfigurations.isEmpty, "libraryConfigurations should not be empty")
        guard let idfaDelegate = configuration.idfaDelegate else {
            XCTFail("idfaDelegate should not be nil")
            return
        }
        XCTAssertTrue(idfaDelegate.isAdvertisingTrackingEnabled, "isAdvertisingTrackingEnabled should be true")
        XCTAssertEqual(idfaDelegate.advertisingIdentifierString, "dummy_idfa", "advertisingIdentifierString should be dummy_idfa")
    }

    func testConfigurationFromPlist() {
        let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-custom-Info", ofType: "plist")
        guard let configuration = KarteCore.Configuration.from(plistPath: path!) else {
            XCTFail("Configuration should not be nil")
            return
        }

        XCTAssertEqual(configuration.appKey, "dummy_application_key_customized", "appKey should be dummy_application_key_customized")
        XCTAssertEqual(configuration.apiKey, "dummy_karte_api_key", "apiKey should be dummy_karte_api_key")
        XCTAssertEqual(configuration.baseURL.absoluteString, "https://b-jp.karte.io", "baseURL should be https://b-jp.karte.io")
        XCTAssertEqual(configuration.dataLocation, "jp", "dataLocation should be jp")
        XCTAssertEqual(configuration.overlayBaseURL.absoluteString, "https://cf-native.karte.io", "overlayBaseURL should be https://cf-native.karte.io")
        XCTAssertFalse(configuration.isDryRun, "isDryRun should be false")
        XCTAssertFalse(configuration.isOptOut, "isOptOut should be false")
        XCTAssertTrue(configuration.isSendInitializationEventEnabled, "isSendInitializationEventEnabled should be true")
        XCTAssertTrue(configuration.libraryConfigurations.isEmpty, "libraryConfigurations should be empty")
        XCTAssertNil(configuration.idfaDelegate, "idfaDelegate should be nil")
    }
}
