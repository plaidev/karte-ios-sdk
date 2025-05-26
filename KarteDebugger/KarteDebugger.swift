//
//  Copyright 2024 PLAID, Inc.
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
import UIKit
import KarteCore
import KarteUtilities

@available(iOS 13.0, *)
@objc(KRTDebugger)
public class KarteDebugger: NSObject {
    private static let userDefaultsKey = "krt_debugger_key"
    static let shared = KarteDebugger()
    
    private(set) var appKey: String?
    private(set) var apiKey: String?
    private(set) var accountId: String?

    override private init() {}

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }
}

@available(iOS 13.0, *)
extension KarteDebugger: Library {
    public static var name: String {
        "karte_debugger"
    }

    public static var version: String {
        KRTDebuggerCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        app.register(module: .track(shared))
        app.register(module: .deeplink(shared))

        Self.shared.appKey = app.configuration.appKey
        Self.shared.apiKey = app.configuration.apiKey
        Self.shared.accountId = UserDefaults.standard.string(forKey: Self.userDefaultsKey)
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .deeplink(shared))
    }
}

@available(iOS 13.0, *)
extension KarteDebugger: TrackModule {
    static let path = "v0/native/auto-track/app-trace"

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {

        // OPTOUTの場合はイベントを送信しない
        if KarteApp.isOptOut { return urlRequest }

        guard let url = URL(string: "\(KarteApp.configuration.baseURL)/\(Self.path)") else {
            Logger.warn(tag: .debugger, message: "Malformed URL: \(KarteApp.configuration.baseURL)/\(Self.path)")
            return urlRequest
        }
        
        if let body = urlRequest.httpBody,
           let appKey = Self.shared.appKey,
           let apiKey = Self.shared.apiKey,
           let accountId = Self.shared.accountId {
            Task.detached {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue(apiKey, forHTTPHeaderField: "__api_auth_data__")
                request.setValue(appKey, forHTTPHeaderField: "X-KARTE-App-Key")
                request.setValue(accountId, forHTTPHeaderField: "X-KARTE-Auto-Track-Account-Id")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = body
                if isGzipped(body) {
                    request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
                }

                do {
                    _ = try await URLSession.shared.data(for: request)
                } catch {
                    Logger.warn(tag: .debugger, message: "URLSession error: \(error)")
                }
            }
        }
        return urlRequest
    }
}

@available(iOS 13.0, *)
extension KarteDebugger: DeepLinkModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public func handle(app: UIApplication, open url: URL) -> Bool {
        let accountId = UserDefaults.standard.string(forKey: Self.userDefaultsKey) ?? ""
        if accountId.isEmpty {
            // NOTE: URL Spec: {customScheme}//karte.io/_krt_app_sdk_debugger/{accountId}
            guard url.pathComponents.contains("_krt_app_sdk_debugger") else {
                Logger.warn(tag: .debugger, message: "Handling deeplink: invalid pathComponents: \(url.pathComponents)")
                return false
            }
            
            guard !url.lastPathComponent.isEmpty else {
                Logger.warn(tag: .debugger, message: "Connecting Debugger but missing accountId")
                return false
            }

            let id = url.lastPathComponent
            Logger.info(tag: .debugger, message: "Handling deeplink, storing accountId: \(id)")
            UserDefaults.standard.setValue(id, forKey: Self.userDefaultsKey)
        }

        return true
    }
}

extension Logger.Tag {
    static let debugger = Logger.Tag("KarteDebugger", version: KRTDebuggerCurrentLibraryVersion())
}
