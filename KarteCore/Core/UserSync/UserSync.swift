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

import Foundation
import KarteUtilities
import WebKit

/// WebView 連携するためのクラスです。
///
/// WebページURLに連携用のクエリパラメータを付与した状態で、URLをWebViewで開くことでWebとAppのユーザーの紐付けが行われます。<br>
/// なお連携を行うためにはWebページに、KARTEのタグが埋め込まれている必要があります。
@objc(KRTUserSync)
public class UserSync: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case visitorId = "visitor_id"
        case appInfo = "app_info"
        case timestamp = "ts"
        case deactivate = "_karte_tracker_deactivate"
    }

    var visitorId: String?
    var appInfo: AppInfo?
    var timestamp: Date?
    var deactivate: Bool = false

    var rawValue: String? {
        if !deactivate && visitorId == nil {
            Logger.warn(tag: .core, message: "KarteApp.setup is not called.")
            return nil
        }
        do {
            let data = try createJSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            Logger.error(tag: .core, message: "Failed to construct JSON string: \(error)")
            return nil
        }
    }

    init(_ timestamp: Date = Date()) {
        if KarteApp.isOptOut {
            self.deactivate = true
        } else if let appInfo = KarteApp.shared.appInfo {
            self.visitorId = KarteApp.visitorId
            self.appInfo = appInfo
            self.timestamp = timestamp
        }
    }

    /// 指定されたURL文字列にWebView連携用のクエリパラメータを付与します。
    ///
    /// - Parameter urlString: 連携するページのURL文字列
    /// - Returns: 連携用のクエリパラメータを付与したURL文字列を返します。指定されたURL文字列の形式が正しくない場合、またはSDKの初期化が行われていない場合は、引数に指定したURL文字列を返します。
    @objc(appendingQueryParameterWithURLString:)
    public static func appendingQueryParameter(_ urlString: String) -> String {
        UserSync().appendingQueryParameter(urlString)
    }

    /// 指定されたURLにWebView連携用のクエリパラメータを付与します。
    ///
    /// - Parameter url: 連携するページのURL
    /// - Returns: 連携用のクエリパラメータを付与したURLを返します。SDKの初期化が行われていない場合は、引数に指定したURLを返します。
    @objc(appendingQueryParameterWithURL:)
    public static func appendingQueryParameter(_ url: URL) -> URL {
        UserSync().appendingQueryParameter(url)
    }

    /// WKWebViewに連携用のスクリプトを設定します。<br>
    /// スクリプトはユーザースクリプトとして設定されます。
    ///
    /// なおSDKの初期化が行われていない場合は設定されません。
    ///
    /// - Parameter webView: `WKWebView`
    @objc(setUserSyncScriptWithWebView:)
    public static func setUserSyncScript(_ webView: WKWebView) {
        UserSync().setUserSyncScript(webView)
    }

    func appendingQueryParameter(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else {
            Logger.error(tag: .core, message: "Invalid url string is set.")
            return urlString
        }
        return self.appendingQueryParameter(url).absoluteString
    }

    func appendingQueryParameter(_ url: URL) -> URL {
        guard let parameter = self.rawValue, let data = parameter.data(using: .utf8) else {
            Logger.error(tag: .core, message: "Failed to append sync query parameter.")
            return url
        }
        let base64EncodedParameter = data.base64EncodedString()
        let userSyncQueryItem = URLQueryItem(name: "_k_ntvsync_b", value: base64EncodedParameter)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            Logger.error(tag: .core, message: "Invalid url is set.")
            return url
        }
        components.queryItems = [userSyncQueryItem] + (components.queryItems ?? [])
        return components.url ?? url
    }

    func setUserSyncScript(_ webView: WKWebView) {
        guard let parameter = self.rawValue else {
            Logger.error(tag: .core, message: "Failed to set sync user script.")
            return
        }
        let source = "window.__karte_ntvsync = \(parameter);"

        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
    }

    deinit {
    }
}
