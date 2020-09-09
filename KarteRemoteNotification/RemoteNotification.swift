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
import KarteUtilities
import UIKit

/// リモート通知メッセージのパースおよびメッセージ中に含まれるディープリンクのハンドリングを行うためのクラスです。
@objc(KRTRemoteNotification)
public class RemoteNotification: NSObject {
    /// 通知のクリック計測を自動で行うかどうかを表すフラグを返します。<br>
    /// フラグを `false` にした場合は、自動でのクリック計測が行われません。<br>
    /// デフォルトは `true` です。
    ///
    /// **本フラグの設定は `KarteApp.setup(appKey:)` を呼び出す前に行う必要があります。**
    @objc public class var isEnabledAutoMeasurement: Bool {
        get {
            RemoteNotificationProxy.shared.isEnabled
        }
        set {
            RemoteNotificationProxy.shared.isEnabled = newValue
        }
    }

    private var userInfo: [AnyHashable: Any]

    /// 通知メッセージ中に含まれる `URL` を返します。
    /// 以下の場合は、nil を返します。
    /// - KARTE以外から送信されたメッセージ
    /// - メッセージ中に `URL` が含まれていない場合
    /// - 不正なURL
    @objc public var url: URL? {
        guard let string = userInfo["krt_attributes"] as? String else {
            Logger.error(tag: .notification, message: "krt_attributes is nil.")
            return nil
        }
        guard let data = string.data(using: .utf8) else {
            Logger.error(tag: .notification, message: "Failed to convert to data.")
            return nil
        }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
            Logger.error(tag: .notification, message: "Failed to parse. \(string)")
            return nil
        }
        guard let attributes = object as? [String: Any] else {
            Logger.error(tag: .notification, message: "Failed to cast.")
            return nil
        }
        guard let urlString = attributes["url"] as? String else {
            Logger.warn(tag: .notification, message: "Deeplink URL is nil.")
            return nil
        }
        guard let url = conformToRFC2396(urlString: urlString) else {
            Logger.warn(tag: .notification, message: "Failed to parse URL. \(urlString)")
            return nil
        }
        return url
    }

    /// インスタンスを初期化します。
    /// なおリモート通知メッセージが KARTE から送信されたメッセージでない場合は、nil を返します。
    /// - Parameter userInfo: リモート通知メッセージ
    @objc
    public init?(userInfo: [AnyHashable: Any]) {
        if userInfo[RemoteNotificationKey.push.rawValue] == nil && userInfo[RemoteNotificationKey.massPush.rawValue] == nil {
            return nil
        }
        self.userInfo = userInfo
    }

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    /// リモート通知メッセージに含まれるディープリンクを処理します。
    /// 内部では、メッセージ中に含まれるURLを `UIApplication.open(_:options:completionHandler:)` に渡す処理を行っています。
    ///
    /// `UIApplication.open(_:options:completionHandler:)` の呼び出しが行われた場合は `true` を返し、メッセージ中にURLが含まれない場合は `false` を返します。
    @objc
    @discardableResult
    public func handle() -> Bool {
        guard let url = self.url else {
            Logger.info(tag: .notification, message: "This message was not sent by KARTE.")
            return false
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        return true
    }

    /// 通知のクリック計測を行います。<br>
    /// 通常は自動でクリック計測が行われるため本メソッドを呼び出す必要はありませんが、
    /// `isEnabledAutoMeasurement` が `false` の場合は自動での計測が行われないため、
    /// 本メソッドを呼び出す必要があります。
    @objc
    public func track() {
        Measurement.measure(userInfo: userInfo)
    }

    deinit {
    }
}

extension RemoteNotification: Library {
    public static var name: String {
        "remote_notification"
    }

    public static var version: String {
        KRTRemoteNotificationCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        app.register(module: .user(FCMTokenRegistrar.shared))
        app.register(module: .notification(FCMTokenRegistrar.shared))
        app.register(module: .deeplink(NotificationCommandHandler.shared))

        if RemoteNotificationProxy.shared.canSwizzleMethods {
            RemoteNotificationProxy.shared.swizzleMethods()
        }
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .user(FCMTokenRegistrar.shared))
        app.unregister(module: .notification(FCMTokenRegistrar.shared))
        app.unregister(module: .deeplink(NotificationCommandHandler.shared))

        if RemoteNotificationProxy.shared.canSwizzleMethods {
            RemoteNotificationProxy.shared.unswizzleMethods()
        }
    }
}

extension Logger.Tag {
    static let notification = Logger.Tag("RN", version: KRTRemoteNotificationCurrentLibraryVersion())
}
