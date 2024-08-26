//
//  InAppMessagingConfiguration.swift
//  Pods
//
//  Created by Tomoki Koga on 2023/11/27.
//

import KarteCore

/// InAppMessagingモジュールの設定を保持するクラスです。
@objc(KRTInAppMessagingConfiguration)
public class InAppMessagingConfiguration: NSObject, LibraryConfiguration {
    /// WKWebView配下のRemoteView検出をスキップするためのフラグです。<br>
    /// フラグを `true` にした場合は、RemoteView検出がスキップされます。<br>
    /// デフォルトは `false` です。
    @objc public var isSkipRemoteViewDetectionInWebView = false

    /// SDK側で画面境界を自動で認識する機能<br>
    /// フラグを `true` にした場合は、SDK側で画面境界が自動で認識されます。<br>
    /// フラグを `false` にした場合は、viewイベントの発火以外では画面境界が認識されません。<br>
    /// 詳細は https://developers.karte.io/docs/concepts-boundary-transition-ios-sdk-v2 をご確認ください<br>
    /// デフォルトは `true` です。
    @objc public var isAutoScreenBoundaryEnabled = true

    deinit {}
}
