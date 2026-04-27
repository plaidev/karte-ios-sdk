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
import WebKit
import KarteUtilities
@testable import KarteCore

let url = URL(string: "https://example.com/dummy")!

func GetQueryItem(with url: URL?) -> UserSync? {
    guard let url = url else {
        return nil
    }

    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard let items = components?.queryItems else {
        return nil
    }
    guard let item = items.first(where: { $0.name == "_k_ntvsync_b" }), let value = item.value else {
        return nil
    }

    let restoreData = Data(base64Encoded: value)
    let restoreString = String(data: restoreData!, encoding: .utf8)
    return GetQueryItem(with: restoreString)
}

func GetQueryItem(with query: String?) -> UserSync? {
    guard let data = query?.data(using: .utf8) else {
        return nil
    }
    let parameter = try? createJSONDecoder().decode(UserSync.self, from: data)
    return parameter
}

@MainActor
class UserSyncSpec: XCTestCase {

    func testRawValueWhenNotSetup() {
        let parameter = UserSync().rawValue
        XCTAssertNil(parameter, "rawValue should be nil when app is not setup")
    }

    func testAppendingQueryParameterWhenNotSetup() {
        let retString = UserSync.appendingQueryParameter(url.absoluteString)
        XCTAssertEqual(retString, url.absoluteString, "appendingQueryParameter(String) should return original URL string")

        let retURL = UserSync.appendingQueryParameter(url)
        XCTAssertEqual(retURL.absoluteString, url.absoluteString, "appendingQueryParameter(URL) should return original URL")
    }

    func testRawValueWhenSetup() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let now = Date(timeIntervalSince1970: 1577836800)
        guard let parameter = UserSync(now).rawValue else {
            XCTFail("rawValue should not be nil when app is setup")
            return
        }
        guard let userSync = GetQueryItem(with: parameter) else {
            XCTFail("GetQueryItem should decode rawValue")
            return
        }

        XCTAssertEqual(userSync.visitorId, "dummy_visitor_id", "visitorId")

        guard let appInfo = userSync.appInfo else {
            XCTFail("appInfo should not be nil")
            return
        }

        XCTAssertEqual(appInfo.versionName, "1.0.0", "app_info.version_name")
        XCTAssertEqual(appInfo.versionCode, "1", "app_info.version_code")
        XCTAssertEqual(appInfo.karteSdkVersion, "1.0.0", "app_info.karte_sdk_version")
        XCTAssertEqual(appInfo.systemInfo.os, "iOS", "app_info.system_info.os")
        XCTAssertEqual(appInfo.systemInfo.osVersion, "13.0", "app_info.system_info.os_version")
        XCTAssertEqual(appInfo.systemInfo.device, "iPhone", "app_info.system_info.device")
        XCTAssertEqual(appInfo.systemInfo.model, "iPhone10,3", "app_info.system_info.model")
        XCTAssertEqual(appInfo.systemInfo.bundleId, "io.karte", "app_info.system_info.bundle_id")
        XCTAssertEqual(appInfo.systemInfo.language, "ja-JP", "app_info.system_info.language")
        XCTAssertEqual(appInfo.systemInfo.idfv, "dummy_idfv", "app_info.system_info.idfv")

        XCTAssertEqual(userSync.timestamp, now, "timestamp")

        XCTAssertEqual(userSync.deactivate, false, "deactivate should be false")
    }

    func testAppendingQueryParameterWhenSetup() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let now = Date(timeIntervalSince1970: 1577836800)
        let syncUrl = UserSync(now).appendingQueryParameter(url)

        XCTAssertEqual(syncUrl.scheme, "https", "scheme")
        XCTAssertEqual(syncUrl.host, "example.com", "host")
        XCTAssertEqual(syncUrl.path, "/dummy", "path")

        guard let userSync = GetQueryItem(with: syncUrl) else {
            XCTFail("GetQueryItem should decode syncUrl")
            return
        }

        XCTAssertEqual(userSync.visitorId, "dummy_visitor_id", "visitorId")

        guard let appInfo = userSync.appInfo else {
            XCTFail("appInfo should not be nil")
            return
        }

        XCTAssertEqual(appInfo.versionName, "1.0.0", "app_info.version_name")
        XCTAssertEqual(appInfo.versionCode, "1", "app_info.version_code")
        XCTAssertEqual(appInfo.karteSdkVersion, "1.0.0", "app_info.karte_sdk_version")
        XCTAssertEqual(appInfo.systemInfo.os, "iOS", "app_info.system_info.os")
        XCTAssertEqual(appInfo.systemInfo.osVersion, "13.0", "app_info.system_info.os_version")
        XCTAssertEqual(appInfo.systemInfo.device, "iPhone", "app_info.system_info.device")
        XCTAssertEqual(appInfo.systemInfo.model, "iPhone10,3", "app_info.system_info.model")
        XCTAssertEqual(appInfo.systemInfo.bundleId, "io.karte", "app_info.system_info.bundle_id")
        XCTAssertEqual(appInfo.systemInfo.language, "ja-JP", "app_info.system_info.language")
        XCTAssertEqual(appInfo.systemInfo.idfv, "dummy_idfv", "app_info.system_info.idfv")

        XCTAssertEqual(userSync.timestamp, now, "timestamp")

        XCTAssertEqual(userSync.deactivate, false, "deactivate should be false")
    }

    func testSetUserSyncScript() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let now = Date()
        guard let parameter = UserSync(now).rawValue else {
            XCTFail("rawValue should not be nil")
            return
        }
        let expectSource = "window.__karte_ntvsync = \(parameter);"
        let webView = WKWebView(frame: .zero)
        UserSync(now).setUserSyncScript(webView)
        let actualSource = webView.configuration.userContentController.userScripts.first?.source
        XCTAssertEqual(actualSource, expectSource, "webview sync script should match rawValue")
    }

    func testGetUserSyncScript() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let now = Date()
        guard let parameter = UserSync(now).rawValue else {
            XCTFail("rawValue should not be nil")
            return
        }
        let expectSource = "window.__karte_ntvsync = \(parameter);"
        let script = UserSync(now).getUserSyncScript()
        XCTAssertEqual(script, expectSource, "getUserSyncScript should match rawValue")
    }

    func testRawValueWhenOptOut() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        KarteApp.optOut()

        guard let parameter = UserSync().rawValue else {
            XCTFail("rawValue should not be nil when opted out")
            return
        }
        guard let userSync = GetQueryItem(with: parameter) else {
            XCTFail("GetQueryItem should decode rawValue")
            return
        }

        XCTAssertNil(userSync.visitorId, "visitorId should be nil when opted out")
        XCTAssertNil(userSync.appInfo, "appInfo should be nil when opted out")
        XCTAssertNil(userSync.timestamp, "timestamp should be nil when opted out")
        XCTAssertTrue(userSync.deactivate, "deactivate should be true when opted out")
    }
}
