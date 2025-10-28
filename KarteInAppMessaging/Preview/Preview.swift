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

import KarteCore
import UIKit

/// アプリ内メッセージのプレビュー処理を行うクラスです。
@objc(KRTPreview)
public class Preview: NSObject {
    private static let shared = Preview()
    private var app: KarteApp?

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    deinit {
    }
}

extension Preview: Library {
    public static var name: String {
        String(describing: self)
    }

    public static var version: String {
        KRTInAppMessagingCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        false
    }

    public static func configure(app: KarteApp) {
        shared.app = app
        app.register(module: .deeplink(shared))
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .deeplink(shared))
        shared.app = nil
    }
}

extension Preview: DeepLinkModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public func handle(app: UIApplication, open url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        let sequence = (components.queryItems ?? []).compactMap { queryItem -> (String, String)? in
            queryItem.value.map { (queryItem.name, $0) }
        }
        let queries = Dictionary(uniqueKeysWithValues: sequence)

        guard let app = self.app, let appInfo = app.appInfo else {
            return false
        }
        guard let id = queries["preview_id"], let token = queries["preview_token"], queries["__krt_preview"] != nil else {
            return false
        }
        guard let url = PreviewURL(app: app, previewId: id, previewToken: token, appInfo: appInfo).build() else {
            return false
        }

        KarteApp.optOutTemporarily()
        InAppMessaging.shared.preview(url: url)
        return true
    }
}
