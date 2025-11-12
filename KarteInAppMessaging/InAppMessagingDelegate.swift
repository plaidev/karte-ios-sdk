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
    /// このメソッドは非推奨です。`inAppMessagingWindowIsPresented(_:onScene:)` を使用してください。
    /// 通常、このメソッドは呼び出されず、代わりに `inAppMessagingWindowIsPresented(_:onScene:)` が呼び出されます。
    ///
    /// - Parameter inAppMessaging: アプリ内メッセージインスタンス
    @available(*, deprecated, message: "Use inAppMessagingWindowIsPresented(_:onScene:) instead.")
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
    /// このメソッドは非推奨です。`inAppMessagingWindowIsDismissed(_:onScene:)` を使用してください。
    /// 通常、このメソッドは呼び出されず、代わりに `inAppMessagingWindowIsDismissed(_:onScene:)` が呼び出されます。
    ///
    /// - Parameter inAppMessaging: アプリ内メッセージインスタンス
    @available(*, deprecated, message: "Use inAppMessagingWindowIsDismissed(_:onScene:) instead.")
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
    /// このメソッドは非推奨です。`inAppMessagingIsPresented(_:campaignId:shortenId:onScene:)` を使用してください。
    /// 通常、このメソッドは呼び出されず、代わりに `inAppMessagingIsPresented(_:campaignId:shortenId:onScene:)` が呼び出されます。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    @available(*, deprecated, message: "Use inAppMessagingIsPresented(_:campaignId:shortenId:onScene:) instead.")
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
    /// このメソッドは非推奨です。`inAppMessagingIsDismissed(_:campaignId:shortenId:onScene:)` を使用してください。
    /// 通常、このメソッドは呼び出されず、代わりに `inAppMessagingIsDismissed(_:campaignId:shortenId:onScene:)` が呼び出されます。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - campaignId: 接客サービスのキャンペーンID
    ///   - shortenId: 接客サービスアクションの短縮ID
    @available(*, deprecated, message: "Use inAppMessagingIsDismissed(_:campaignId:shortenId:onScene:) instead.")
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
    /// このメソッドは非推奨です。`inAppMessaging(_:shouldOpenURL:onScene:)` を使用してください。
    /// 通常、このメソッドは呼び出されず、代わりに `inAppMessaging(_:shouldOpenURL:onScene:)` が呼び出されます。
    ///
    /// - Parameters:
    ///   - inAppMessaging: アプリ内メッセージインスタンス
    ///   - url: リンクURL
    /// - Returns: `true` を返した場合はSDK側でリンクを自動で開きます。`false` を返した場合はSDK側では何もしません。
    @available(*, deprecated, message: "Use inAppMessaging(_:shouldOpenURL:onScene:) instead.")
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
