//
//  InAppMessagingConfiguration.swift
//  Pods
//
//  Created by Tomoki Koga on 2023/11/27.
//

public import KarteCore

/// InAppMessagingモジュールの設定を保持するクラスです。
@objc(KRTInAppMessagingConfiguration)
public class InAppMessagingConfiguration: NSObject, LibraryConfiguration {
    /// 本SDKでは、iOS 26未満で、View階層に`_UIRemoteView`が含まれる場合に、アプリ内メッセージと干渉しうるシステムUIが存在するとみなし、アプリ内メッセージを非表示にする仕組みがあります。<br>
    /// WKWebViewの配下に`_UIRemoteView`が含まれる場合に限り、この仕組みを無効化するためのフラグです。<br>
    /// なお、本オプションが`true`の場合、iOS 26以上では、`isSkipSystemUIDetectionInWebView`を`true`にした場合と同じ動作になります。<br>
    /// デフォルトは `false` です。
    @available(iOS, deprecated: 26.0, message: "This option should not be used on iOS 26 or later.")
    @objc public var isSkipRemoteViewDetectionInWebView = false

    /// **非推奨**: 基本的に本オプションを使用すべき場面はありません。将来のバージョンで削除する予定です。<br>
    /// 本SDKでは、iOS 26以降で、所定のViewControllerが表示されている場合に、アプリ内メッセージと干渉しうるシステムUIが存在するとみなし、アプリ内メッセージを非表示にする仕組みがあります。<br>
    /// この仕組みを無効化するためのフラグです。<br>
    /// なお、本オプションが`true`の場合、iOS 26未満では、`isSkipRemoteViewDetectionInWebView`を`true`にした場合と同じ動作になります。<br>
    /// デフォルトは `false` です。
    @available(*, deprecated, message: "This option should generally not be used. It will be removed in a future version.")
    @objc public var isSkipSystemUIDetectionInWebView = false

    /// SDK側で画面境界を自動で認識する機能<br>
    /// フラグを `true` にした場合は、SDK側で画面境界が自動で認識されます。<br>
    /// フラグを `false` にした場合は、viewイベントの発火以外では画面境界が認識されません。<br>
    /// 詳細は https://developers.karte.io/docs/concepts-boundary-transition-ios-sdk-v2 をご確認ください<br>
    /// デフォルトは `true` です。
    @objc public var isAutoScreenBoundaryEnabled = true

    deinit {}
}
