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

/// アプリ内メッセージで発生するイベントを委譲するためのタイプです。
@preconcurrency @MainActor @objc(KRTInAppMessagingDelegate)
public protocol InAppMessagingDelegate: AnyObject {
    /// アプリ内メッセージ用のWindowが表示されたことを通知します。
    ///
    /// なお iOS13 または iPadOS で実行されている場合かつ `inAppMessagingWindowIsPresented(_:onScene:)` が実装されている場合は、本メソッドは呼び出されません。
    ///
    /// - Parameter inAppMessaging: アプリ内メッセージインスタンス
    @objc
    optional func inAppMessagingWindowIsPresented(_ inAppMessaging: InAppMessaging)

    /// アプリ内メッセージ用のWindowが表示されたことを通知します。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - scene: シーン
    @objc
    optional func inAppMessagingWindowIsPresented(_ inAppMessaging: InAppMessaging, onScene scene: UIScene)

    /// アプリ内メッセージ用のWindowが非表示になったことを通知します。
    ///
    /// なお iOS13 または iPadOS で実行されている場合かつ `inAppMessagingWindowIsDismissed(_:onScene:)` が実装されている場合は、本メソッドは呼び出されません。
    ///
    /// - Parameter inAppMessaging: アプリ内メッセージインスタンス
    @objc
    optional func inAppMessagingWindowIsDismissed(_ inAppMessaging: InAppMessaging)

    /// アプリ内メッセージ用のWindowが非表示になったことを通知します。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - scene: シーン
    @objc
    optional func inAppMessagingWindowIsDismissed(_ inAppMessaging: InAppMessaging, onScene scene: UIScene)

    /// 接客サービスアクションが表示されたことを通知します。
    ///
    /// なお iOS13 または iPadOS で実行されている場合かつ `inAppMessagingIsPresented(_:onScene:campaignId:shortenId)` が実装されている場合は、本メソッドは呼び出されません。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    @objc
    optional func inAppMessagingIsPresented(_ inAppMessaging: InAppMessaging, campaignId: String, shortenId: String)

    /// 接客サービスアクションが表示されたことを通知します。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    ///   - scene: シーン
    @objc
    optional func inAppMessagingIsPresented(_ inAppMessaging: InAppMessaging, campaignId: String, shortenId: String, onScene scene: UIScene)

    /// 接客サービスアクションが非表示になったことを通知します。
    ///
    /// なお iOS13 または iPadOS で実行されている場合かつ `inAppMessagingIsDismissed(_:onScene:campaignId:shortenId)` が実装されている場合は、本メソッドは呼び出されません。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    @objc
    optional func inAppMessagingIsDismissed(_ inAppMessaging: InAppMessaging, campaignId: String, shortenId: String)

    /// 接客サービスアクションが非表示になったことを通知します。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    ///   - scene: シーン
    @objc
    optional func inAppMessagingIsDismissed(_ inAppMessaging: InAppMessaging, campaignId: String, shortenId: String, onScene scene: UIScene)

    /// 接客サービスアクション中のボタンがクリックされた際に、リンクをSDK側で自動的に処理するかどうか問い合わせます。
    ///
    /// なお iOS13 または iPadOS で実行されている場合かつ `inAppMessaging(_:onScene:shouldOpenURL:campaignId:shortenId)` が実装されている場合は、本メソッドは呼び出されません。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - url: リンクURL
    /// - Returns: `true` を返した場合はSDK側でリンクを自動で開きます。`false` を返した場合はSDK側では何もしません。
    @objc
    optional func inAppMessaging(_ inAppMessaging: InAppMessaging, shouldOpenURL url: URL) -> Bool

    /// 接客サービスアクション中のボタンがクリックされた際に、リンクをSDK側で自動的に処理するかどうか問い合わせます。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - url: リンクURL
    ///   - scene: シーン
    /// - Returns: `true` を返した場合はSDK側でリンクを自動で開きます。`false` を返した場合はSDK側では何もしません。
    @objc
    optional func inAppMessaging(_ inAppMessaging: InAppMessaging, shouldOpenURL url: URL, onScene scene: UIScene) -> Bool
}
