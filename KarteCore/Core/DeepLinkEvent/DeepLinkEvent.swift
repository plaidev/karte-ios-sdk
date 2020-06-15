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

/// deep link イベントを処理するためのクラスです。
///
/// **SDK内部で利用するクラスであり、通常のSDK利用でこちらのクラスを利用することはありません。**
@objc(KRTDeepLinkEvent)
public class DeepLinkEvent: NSObject {
    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    deinit {
    }
}

extension DeepLinkEvent: Library {
    public static var name: String {
        String(describing: self)
    }

    public static var version: String {
        "1.0.0"
    }

    public static var isPublic: Bool {
        false
    }

    public static func configure(app: KarteApp) {
        app.register(module: .deeplink(DeepLinkEvent()))
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .deeplink(DeepLinkEvent()))
    }
}

extension DeepLinkEvent: DeepLinkModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public func handle(app: UIApplication, open url: URL) -> Bool {
        let event = Event(.deepLinkAppOpen(url: url.absoluteString))
        Tracker.track(event: event)
        return false
    }
}
