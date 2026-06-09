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
import KarteUtilities
import Foundation

let APP_KEY_OVERWRITED = APP_KEY.uppercased()
let APP_KEY_FROM_PLIST = "dummy_application_key_from_plist"
let APP_KEY_FROM_CUSTOM = "dummy_application_key_customized"
let API_KEY = "dummy_api_key"
let API_KEY_FROM_CUSTOM = "dummy_karte_api_key"

class SetupSpec: XCTestCase {
    var session: TrackClientSessionMock!
    var builder: Builder!

    override func setUp() {
        super.setUp()
        session = TrackClientSessionMock()
        Resolver.root = Resolver.submock
        Resolver.root.register { self.session as TrackClientSession }
        builder = StubBuilder(spec: Self.self, resource: .empty).build()
    }

    override func tearDown() {
        Resolver.root = Resolver.mock
        super.tearDown()
    }

    // MARK: - Helpers

    private var customPlistPath: String {
        Bundle(for: SetupSpec.self).path(forResource: "Karte-custom-Info", ofType: "plist")!
    }

    private func setupApp(_ config: Configuration, appKey: String? = nil) {
        if let appKey = appKey {
            KarteApp.setup(appKey: appKey, configuration: config)
        } else {
            KarteApp.setup(configuration: config)
        }
    }

    private func setupApp(_ config: ExperimentalConfiguration, appKey: String? = nil) {
        if let appKey = appKey {
            KarteApp.setup(appKey: appKey, configuration: config)
        } else {
            KarteApp.setup(configuration: config)
        }
    }

    private func makeConfigWithAppKeyAndApiKey() -> Configuration {
        let config = Configuration()
        config.appKey = APP_KEY
        config.apiKey = API_KEY
        return config
    }

    // MARK: - Assertion helpers

    private func assertDefaultTrackingRequest(request: URLRequest, body: TrackBody, events: [Event]) {
        XCTAssertEqual(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!, APP_KEY)
        XCTAssertEqual(request.allHTTPHeaderFields!["Content-Encoding"]!, "gzip")
        XCTAssertEqual(request.url!.absoluteString, "https://b.karte.io/v0/native/track")

        let containOpen = events.contains(where: { $0.eventName == .nativeAppOpen })
        XCTAssertTrue(containOpen)

        let containInstall = events.contains(where: { $0.eventName == .nativeAppInstall })
        XCTAssertTrue(containInstall)

        let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
        XCTAssertNil(dummy)

        XCTAssertTrue(KarteApp.shared.configuration.apiKey.isEmpty)
        XCTAssertNil(body.appInfo.systemInfo.idfa)
    }

    private func assertCustomBaseURL(
        _ config: Configuration,
        appKey: String?,
        expectAppKey: String,
        expectApiKey: String?
    ) {
        let module = StubActionModule(builder: builder)
        config.baseURL = URL(string: "https://t.karte.io")!
        config.overlayBaseURL = URL(string: "https://api.karte.io")!
        setupApp(config, appKey: appKey)

        let request = module.wait().request(.nativeAppOpen)

        XCTAssertEqual(request?.allHTTPHeaderFields!["X-KARTE-App-Key"]!, expectAppKey)
        XCTAssertEqual(request?.url?.absoluteString, "https://t.karte.io/v0/native/track")
        XCTAssertEqual(KarteApp.shared.configuration.overlayBaseURL.absoluteString, "https://api.karte.io")
        if let expectApiKey = expectApiKey {
            XCTAssertEqual(KarteApp.shared.configuration.apiKey, expectApiKey)
        }
    }

    private func assertDryRun(_ config: Configuration, appKey: String? = nil) {
        config.isDryRun = true
        setupApp(config, appKey: appKey)
        XCTAssertNil(KarteApp.shared.trackingClient)
    }

    private func assertOptOut(_ config: Configuration, appKey: String? = nil) {
        config.isOptOut = true
        setupApp(config, appKey: appKey)
        XCTAssertNotNil(KarteApp.shared.trackingClient)
        XCTAssertTrue(KarteApp.isOptOut)
    }

    private func assertLibraryConfigRegistered(_ config: Configuration, appKey: String? = nil) {
        let commandCountObserver = CommandCountObserver(expectedCommandCount: 2)
        config.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
        setupApp(config, appKey: appKey)
        commandCountObserver.wait()
        let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
        XCTAssertNotNil(dummy)
    }

    private func assertIdfaDisabled(_ config: Configuration, appKey: String? = nil) {
        let idfa = IDFA(isEnabled: false, idfa: "dummy_idfa")
        let commandCountObserver = CommandCountObserver(expectedCommandCount: 2)
        let module = StubActionModule(builder: builder)
        config.idfaDelegate = idfa
        setupApp(config, appKey: appKey)
        let body = module.wait().body(.nativeAppOpen)
        commandCountObserver.wait()
        XCTAssertNil(body?.appInfo.systemInfo.idfa)
        withExtendedLifetime(idfa) {}
    }

    private func assertIdfaEnabled(_ config: Configuration, appKey: String? = nil) {
        let idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
        let commandCountObserver = CommandCountObserver(expectedCommandCount: 2)
        let module = StubActionModule(builder: builder)
        config.idfaDelegate = idfa
        setupApp(config, appKey: appKey)
        let body = module.wait().body(.nativeAppOpen)
        commandCountObserver.wait()
        XCTAssertEqual(body?.appInfo.systemInfo.idfa, "dummy_idfa")
        withExtendedLifetime(idfa) {}
    }

    private func assertIngestMode(_ config: ExperimentalConfiguration, appKey: String? = nil) {
        let commandCountObserver = CommandCountObserver(expectedCommandCount: 2)
        let module = StubActionModule(path: "/v0/native/ingest", builder: builder)
        config.operationMode = .ingest
        config.baseURL = URL(string: "https://api.karte.io")!
        setupApp(config, appKey: appKey)
        let request = module.wait().request(.nativeAppOpen)
        commandCountObserver.wait()
        XCTAssertEqual(request?.url?.absoluteString, "https://api.karte.io/v0/native/ingest")
    }

    // MARK: - Setup with appKey param - Default config

    func testSetupWithAppKeyDefaultConfig() {
        let module = StubActionModule(builder: builder)
        KarteApp.setup(appKey: APP_KEY)

        var request: URLRequest!
        var body: TrackBody!
        var events: [Event] = []
        module.wait().responseDatas([.nativeAppOpen, .nativeAppInstall]).forEach { data in
            request = data.request
            body = data.body
            events.append(data.event)
        }

        assertDefaultTrackingRequest(request: request, body: body, events: events)
    }

    // MARK: - Setup with appKey param - Config from default plist

    func testSetupWithAppKeyFromDefaultPlist_CustomBaseURL() {
        assertCustomBaseURL(Configuration.default!, appKey: APP_KEY_OVERWRITED, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: nil)
    }

    func testSetupWithAppKeyFromDefaultPlist_DryRun() {
        assertDryRun(Configuration.default!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromDefaultPlist_OptOut() {
        assertOptOut(Configuration.default!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromDefaultPlist_LibraryConfig() {
        assertLibraryConfigRegistered(Configuration.default!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromDefaultPlist_IdfaDisabled() {
        assertIdfaDisabled(Configuration.default!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromDefaultPlist_IdfaEnabled() {
        assertIdfaEnabled(Configuration.default!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromDefaultPlist_IngestMode() {
        assertIngestMode(ExperimentalConfiguration.default!, appKey: APP_KEY_OVERWRITED)
    }

    // MARK: - Setup with appKey param - Config from custom plist

    func testSetupWithAppKeyFromCustomPlist_CustomBaseURL() {
        assertCustomBaseURL(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: API_KEY_FROM_CUSTOM)
    }

    func testSetupWithAppKeyFromCustomPlist_DryRun() {
        assertDryRun(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromCustomPlist_OptOut() {
        assertOptOut(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromCustomPlist_LibraryConfig() {
        assertLibraryConfigRegistered(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromCustomPlist_IdfaDisabled() {
        assertIdfaDisabled(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromCustomPlist_IdfaEnabled() {
        assertIdfaEnabled(Configuration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    func testSetupWithAppKeyFromCustomPlist_IngestMode() {
        assertIngestMode(ExperimentalConfiguration.from(plistPath: customPlistPath)!, appKey: APP_KEY_OVERWRITED)
    }

    // MARK: - Setup with appKey param - Plain config (no plist)

    func testSetupWithAppKeyPlainConfig_CustomBaseURL() {
        assertCustomBaseURL(Configuration(), appKey: APP_KEY, expectAppKey: APP_KEY, expectApiKey: nil)
    }

    func testSetupWithAppKeyPlainConfig_DryRun() {
        assertDryRun(Configuration(), appKey: APP_KEY)
    }

    func testSetupWithAppKeyPlainConfig_OptOut() {
        assertOptOut(Configuration(), appKey: APP_KEY)
    }

    func testSetupWithAppKeyPlainConfig_LibraryConfig() {
        assertLibraryConfigRegistered(Configuration(), appKey: APP_KEY)
    }

    func testSetupWithAppKeyPlainConfig_IdfaDisabled() {
        assertIdfaDisabled(Configuration(), appKey: APP_KEY)
    }

    func testSetupWithAppKeyPlainConfig_IdfaEnabled() {
        assertIdfaEnabled(Configuration(), appKey: APP_KEY)
    }

    func testSetupWithAppKeyPlainConfig_IngestMode() {
        assertIngestMode(ExperimentalConfiguration(), appKey: APP_KEY)
    }

    // MARK: - Setup with appKey param - Config with appKey by setter

    func testSetupWithAppKeyAppKeyBySetter_CustomBaseURL() {
        assertCustomBaseURL(makeConfigWithAppKeyAndApiKey(), appKey: APP_KEY_OVERWRITED, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: API_KEY)
    }

    // MARK: - Setup with appKey param - Config with appKey by configurator

    func testSetupWithAppKeyAppKeyByConfigurator_CustomBaseURL() {
        assertCustomBaseURL(Configuration { $0.appKey = APP_KEY }, appKey: APP_KEY_OVERWRITED, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: nil)
    }

    // MARK: - Setup with appKey param - Config with appKey by initializer

    func testSetupWithAppKeyAppKeyByInitializer_CustomBaseURL() {
        assertCustomBaseURL(Configuration(appKey: APP_KEY), appKey: APP_KEY_OVERWRITED, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: nil)
    }

    // MARK: - Setup without appKey param - Default config

    func testSetupWithoutAppKeyDefaultConfig() {
        let module = StubActionModule(builder: builder)
        KarteApp.setup()

        var request: URLRequest!
        var body: TrackBody!
        var events: [Event] = []
        module.wait().responseDatas([.nativeAppOpen, .nativeAppInstall]).forEach { data in
            request = data.request
            body = data.body
            events.append(data.event)
        }

        assertDefaultTrackingRequest(request: request, body: body, events: events)
    }

    // MARK: - Setup without appKey param - Config from default plist

    func testSetupWithoutAppKeyFromDefaultPlist_CustomBaseURL() {
        assertCustomBaseURL(Configuration.default!, appKey: nil, expectAppKey: APP_KEY_FROM_PLIST, expectApiKey: nil)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_DryRun() {
        assertDryRun(Configuration.default!)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_OptOut() {
        assertOptOut(Configuration.default!)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_LibraryConfig() {
        assertLibraryConfigRegistered(Configuration.default!)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_IdfaDisabled() {
        assertIdfaDisabled(Configuration.default!)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_IdfaEnabled() {
        assertIdfaEnabled(Configuration.default!)
    }

    func testSetupWithoutAppKeyFromDefaultPlist_IngestMode() {
        assertIngestMode(ExperimentalConfiguration.default!)
    }

    // MARK: - Setup without appKey param - Config from custom plist

    func testSetupWithoutAppKeyFromCustomPlist_CustomBaseURL() {
        assertCustomBaseURL(Configuration.from(plistPath: customPlistPath)!, appKey: nil, expectAppKey: APP_KEY_FROM_CUSTOM, expectApiKey: API_KEY_FROM_CUSTOM)
    }

    func testSetupWithoutAppKeyFromCustomPlist_DryRun() {
        assertDryRun(Configuration.from(plistPath: customPlistPath)!)
    }

    func testSetupWithoutAppKeyFromCustomPlist_OptOut() {
        assertOptOut(Configuration.from(plistPath: customPlistPath)!)
    }

    func testSetupWithoutAppKeyFromCustomPlist_LibraryConfig() {
        assertLibraryConfigRegistered(Configuration.from(plistPath: customPlistPath)!)
    }

    func testSetupWithoutAppKeyFromCustomPlist_IdfaDisabled() {
        assertIdfaDisabled(Configuration.from(plistPath: customPlistPath)!)
    }

    func testSetupWithoutAppKeyFromCustomPlist_IdfaEnabled() {
        assertIdfaEnabled(Configuration.from(plistPath: customPlistPath)!)
    }

    func testSetupWithoutAppKeyFromCustomPlist_IngestMode() {
        assertIngestMode(ExperimentalConfiguration.from(plistPath: customPlistPath)!)
    }

    // MARK: - Setup without appKey param - Config with appKey by setter

    func testSetupWithoutAppKeyAppKeyBySetter_CustomBaseURL() {
        assertCustomBaseURL(makeConfigWithAppKeyAndApiKey(), appKey: nil, expectAppKey: APP_KEY, expectApiKey: API_KEY)
    }

    // MARK: - Setup without appKey param - Config with appKey by configurator

    func testSetupWithoutAppKeyAppKeyByConfigurator_CustomBaseURL() {
        assertCustomBaseURL(Configuration { $0.appKey = APP_KEY }, appKey: nil, expectAppKey: APP_KEY, expectApiKey: nil)
    }

    // MARK: - Setup without appKey param - Config with appKey by initializer

    func testSetupWithoutAppKeyAppKeyByInitializer_CustomBaseURL() {
        assertCustomBaseURL(Configuration(appKey: APP_KEY), appKey: nil, expectAppKey: APP_KEY, expectApiKey: nil)
    }

    // NOTE: throwAssertion() test removed - requires CwlPreconditionTesting/Nimble.
    // The original test verified that KarteApp.setup(configuration: Configuration()) throws an assertion
    // when no appKey is provided and no plist is available.
}
