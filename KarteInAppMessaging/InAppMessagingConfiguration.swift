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

    deinit {}
}
