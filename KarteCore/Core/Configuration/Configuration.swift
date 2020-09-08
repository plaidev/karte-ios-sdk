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

import Foundation

/// SDKの設定を保持するクラスです。
@objc(KRTConfiguration)
@objcMembers
public class Configuration: NSObject, NSCopying {
    /// デフォルト値で初期化された設定インスタンスを返します。
    public static var defaultConfiguration: Configuration {
        Configuration()
    }

    /// ベースURLの取得・設定を行います。
    ///
    /// **SDK内部で利用するプロパティであり、通常のSDK利用でこちらのプロパティを利用することはありません。**
    public var baseURL = URL(string: "https://api.karte.io")!
    // swiftlint:disable:previous force_unwrapping

    /// overlayベースURLの取得・設定を行います。
    ///
    /// **SDK内部で利用するプロパティであり、通常のSDK利用でこちらのプロパティを利用することはありません。**
    public var overlayBaseURL = URL(string: "https://cf-native.karte.io")!
    // swiftlint:disable:previous force_unwrapping

    /// log収集URLの取得・設定を行います。
    ///
    /// **SDK内部で利用するプロパティであり、通常のSDK利用でこちらのプロパティを利用することはありません。**
    var logCollectionURL = URL(string: "https://us-central1-production-debug-log-collector.cloudfunctions.net/nativeAppLogUrl")!
    // swiftlint:disable:previous force_unwrapping

    /// ドライランの利用有無の取得・設定を行います。<br>
    /// ドライランを有効にした場合、`Tracker.track(...)` 等のメソッドを呼び出してもイベントの送信が行われなくなります。
    ///
    /// `true` の場合はドライランが有効となり、`false` の場合は無効となります。<br>
    /// デフォルトは `false` です。
    public var isDryRun = false

    /// オプトアウトの利用有無の取得・設定を行います。
    ///
    /// なお本設定を有効とした場合であっても、明示的に `KarteApp.optIn()` を呼び出した場合はオプトイン状態で動作します。<br>
    /// 本設定はあくまでも、オプトインまたはオプトアウトの表明を行っていない状態での動作設定を決めるものになります。
    ///
    /// `true` の場合はデフォルトでオプトアウトが有効となり、`false` の場合は無効となります。<br>
    /// デフォルトは `false` です。
    public var isOptOut = false

    /// IDFA取得用の委譲先インスタンスの取得・設定を行います。<br>
    /// インスタンスが未設定の場合は、IDFAの情報はイベントに付与されません。
    public weak var idfaDelegate: IDFADelegate?

    // for Test
    var isSendInitializationEventEnabled = true

    /// SDK設定インスタンスを初期化します。
    override public init() {
        super.init()
    }

    /// SDK設定インスタンスを初期化します。
    ///
    /// - Parameter configurator: 初期化ブロック
    public convenience init(configurator: (Configuration) -> Void) {
        self.init()
        configurator(self)
    }

    /// SDK設定インスタンスを初期化します。
    ///
    /// - Parameter configurator: 初期化ブロック
    public class func config(configurator: (Configuration) -> Void) -> Configuration {
        Configuration(configurator: configurator)
    }

    /// インスタンスをコピーします。
    ///
    /// - Parameter zone: NSZone
    public func copy(with zone: NSZone? = nil) -> Any {
        let configuration = Configuration()
        configuration.baseURL = baseURL
        configuration.overlayBaseURL = overlayBaseURL
        configuration.isDryRun = isDryRun
        configuration.isOptOut = isOptOut
        configuration.isSendInitializationEventEnabled = isSendInitializationEventEnabled
        configuration.idfaDelegate = idfaDelegate
        return configuration
    }

    deinit {
    }
}
