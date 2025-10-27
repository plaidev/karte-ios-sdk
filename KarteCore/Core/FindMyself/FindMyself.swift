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

import UIKit

/// find_myself スキームを処理するためのクラスです。
///
/// **SDK内部で利用するクラスであり、通常のSDK利用でこちらのクラスを利用することはありません。**
@objc(KRTFindMyself)
public class FindMyself: NSObject {
    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    deinit {
    }
}

extension FindMyself: Library {
    public static var name: String {
        String(describing: self)
    }

    public static var version: String {
        KRTCoreCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        false
    }

    public static func configure(app: KarteApp) {
        app.register(module: .deeplink(FindMyself()))
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .deeplink(FindMyself()))
    }
}

extension FindMyself: DeepLinkModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public func handle(app: UIApplication, open url: URL) -> Bool {
        guard url.host == "karte.io" && url.path == "/find_myself" else {
            return false
        }

        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return false
        }

        let values = queryItems.reduce(into: [String: JSONConvertible]()) { values, queryItem in
            if let value = queryItem.value {
                values[queryItem.name] = value
            }
        }

        let event = Event(eventName: .nativeFindMyself, values: values)
        Tracker.track(event: event)
        return true
    }
}
