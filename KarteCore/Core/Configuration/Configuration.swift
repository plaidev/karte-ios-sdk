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
import KarteUtilities

/// SDKの設定を保持するクラスです。
@objc(KRTConfiguration)
@objcMembers
public class Configuration: NSObject, NSCopying, Codable {
    enum CodingKeys: String, CodingKey {
        case _appKey = "karte_app_key"
        // swiftlint:disable:previous identifier_name
    }

    /// プロジェクト直下の  Karte-Info.plist をロードしてデフォルト値で初期化された設定インスタンスを返します。
    /// Karte-Info.plist が存在しない場合は nil が返ります。
    public class var `default`: Configuration? {
        guard let path = Resolver.optional(String.self, name: "configuration.path") else {
            let errorMessage = "Karte-Info.plist not found in project root"
            assertionFailure(errorMessage)
            Logger.error(tag: .core, message: errorMessage)
            return nil
        }
        return from(plistPath: path)
    }

    /// デフォルト値で初期化された設定インスタンスを返します。
    public class var defaultConfiguration: Configuration {
        Configuration()
    }

    internal var _appKey = AppKey("")
    // swiftlint:disable:previous identifier_name

    /// アプリケーションキーの取得・設定を行います。
    ///
    /// 設定ファイルから自動でロードされるアプリケーションキー以外を利用したい場合にのみ設定します。
    public var appKey: String {
        get {
            _appKey.value
        }
        set {
            _appKey = AppKey(newValue)
        }
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

    /// ライブラリの設定の取得・設定を行います。
    public var libraryConfigurations: [LibraryConfiguration] = []

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
    /// - Parameter appKey: アプリケーションキー
    public init(appKey: String) {
        self._appKey = AppKey(appKey)
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
    /// **SDK内部で利用する初期化関数であるため、通常のSDK利用においてこちらの関数を利用する必要はありません。**
    /// - Parameter decoder: デコーダー
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._appKey = try container.decode(AppKey.self, forKey: ._appKey)
    }

    /// SDK設定インスタンスを plist ファイルからロードします。
    ///
    /// 指定したパスに有効な plist ファイルが存在しない場合は nil を返します。
    /// - Parameter plistPath: plistのファイルパス
    public class func from(plistPath: String) -> Configuration? {
        let decoder = PropertyListDecoder()

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
            return try decoder.decode(Self.self, from: data)
        } catch {
            let errorMessage = "Decode configuration from plist failed: \(error.localizedDescription)"
            assertionFailure(errorMessage)
            Logger.error(tag: .core, message: errorMessage)
            return nil
        }
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
        configuration._appKey = _appKey
        configuration.baseURL = baseURL
        configuration.overlayBaseURL = overlayBaseURL
        configuration.isDryRun = isDryRun
        configuration.isOptOut = isOptOut
        configuration.isSendInitializationEventEnabled = isSendInitializationEventEnabled
        configuration.libraryConfigurations = libraryConfigurations
        configuration.idfaDelegate = idfaDelegate
        return configuration
    }

    deinit {
    }
}

extension Resolver {
    static func registerConfiguration() {
        register(Configuration.self, name: "configuration") {
            Configuration.default
        }

        register(String.self, name: "configuration.path") {
            Bundle.main.path(forResource: "Karte-Info", ofType: "plist")
        }
    }
}
