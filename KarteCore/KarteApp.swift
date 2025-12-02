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

import KarteUtilities
import UIKit
import AppTrackingTransparency

/// KARTE SDKのエントリポイントであると共に、SDKの構成および依存ライブラリ等の管理を行うクラスです。
///
/// SDKを利用するには、`KarteApp.setup(appKey:)` を呼び出し初期化を行う必要があります。<br>
/// 初期化が行われていない状態では、イベントのトラッキングを始め、SDKの機能が利用できません。<br>
/// なおアプリ内メッセージ等のサブモジュールについても同様です。
///
/// SDKの設定については、初期化時に一部変更することが可能です。
/// 設定を変更して初期化を行う場合は、`KarteApp.setup(appKey:configuration:)`を呼び出してください。
@objc(KRTApp)
public class KarteApp: NSObject {
    static let shared = KarteApp()
    static var libraries: [Library.Type] = []

    private var moduleContainer = ModuleContainer()
    private var coreService: CoreService?

    var trackingClient: TrackingClient?

    deinit {
    }
}

public extension KarteApp {
    /// `KarteApp.setup(appKey:configuration:)` 呼び出し時に指定したアプリケーションキーを返します。
    ///
    /// 初期化が行われていない場合は空文字列を返します。
    @objc class var appKey: String {
        shared.appKey
    }

    /// ユーザーを識別するためのID（ビジターID）を返します。
    ///
    /// 初期化が行われていない場合は空文字列を返します。
    @objc class var visitorId: String {
        shared.visitorId
    }

    /// `KarteApp.setup(appKey:configuration:)` 呼び出し時に指定した設定情報を返します。
    ///
    /// 初期化が行われていない場合はデフォルトの設定情報を返します。
    @objc class var configuration: Configuration {
        shared.configuration
    }

    /// オプトアウトの設定有無を返します。
    ///
    /// オプトアウトされている場合は `true` を返し、されていない場合は `false` を返します。<br>
    /// また初期化が行われていない場合は `false` を返します。
    @objc class var isOptOut: Bool {
        shared.isOptOut
    }

    /// SDKの初期化を行います。
    ///
    /// 初期化オプションが未指定の場合は、デフォルト設定で初期化が行われます。<br>
    /// 初期化オプションのデフォルト値については `Configuration` クラスを参照してください。
    ///
    /// なお初期化後に初期化オプションを変更した場合、その変更はSDKには反映されません。
    ///
    /// また既に初期化されている状態で呼び出した場合は何もしません。
    ///
    /// - Parameters:
    ///   - appKey: アプリケーションキー
    ///   - configuration: 設定
    @objc
    class func setup(appKey: String, configuration: Configuration = Configuration.defaultConfiguration) {
        configuration._appKey = AppKey(appKey)
        shared.setup(configuration: configuration)
    }

    /// SDKの初期化を行います。
    ///
    /// 初期化オプションが未指定の場合は、プロジェクト直下の  Karte-Info.plist をロードして初期化が行われます。<br>
    /// 初期化オプションのデフォルト値については `Configuration.default` を参照してください。
    ///
    /// なお初期化後に初期化オプションを変更した場合、その変更はSDKには反映されません。
    ///
    /// また既に初期化されている状態で呼び出した場合は何もしません。
    ///
    /// - Parameters:
    ///   - configuration: 設定
    @objc
    class func setup(configuration: Configuration? = Resolver.optional(Configuration.self, name: "configuration")) {
        guard let configuration = configuration else {
            Logger.warn(tag: .core, message: "configuration is nil, invalid options has passed or could not find a valid plist in your project.")
            return
        }
        shared.setup(configuration: configuration)
    }

    /// ログレベルを設定します。
    ///
    /// なおデフォルトのログレベルは `LogLevel.error` です。
    ///
    /// - Parameter level: ログレベル
    @objc
    class func setLogLevel(_ level: LogLevel) {
        Logger.level = level
    }

    /// ログ出力有無を設定します。
    ///
    /// ログを出力する場合は `true` を指定し、出力しない場合は `false` を指定します。<br>
    /// デフォルトは `true` です。
    ///
    /// - Parameter isEnabled: ログ出力有無
    @objc
    @available(*, deprecated, message: "setLogEnabled method is deprecated. It will be removed in the future. Use setLogLevel instead.")
    class func setLogEnabled(_ isEnabled: Bool) {
        setLogLevel(isEnabled ? .error : .off)
    }

    /// オプトインします。
    ///
    /// なお初期化が行われていない状態で呼び出した場合はオプトインは行われません。
    @objc
    class func optIn() {
        shared.optIn()
    }

    /// オプトアウトします。
    ///
    /// なお初期化が行われていない状態で呼び出した場合はオプトアウトは行われません。
    @objc
    class func optOut() {
        shared.optOut()
    }

    /// 一時的（アプリの次回起動時まで）にオプトアウトします。
    ///
    /// なお初期化が行われていない状態で呼び出した場合はオプトアウトは行われません。
    @objc
    class func optOutTemporarily() {
        shared.optOutTemporarily()
    }

    /// ビジターIDを再生成します。
    ///
    /// ビジターIDの再生成は、現在のユーザーとは異なるユーザーとして計測したい場合などに行います。<br>
    /// 例えば、アプリケーションでログアウトした際などがこれに該当します。
    ///
    /// なお初期化が行われていない状態で呼び出した場合は再生成は行われません。
    @objc
    class func renewVisitorId() {
        shared.renewVisitorId()
    }

    /// AppTrackingTransparencyの許諾状況をKARTE側に送信します。
    ///
    /// att_status_updatedというイベント経由で送信許諾状況を送信しています。
    ///
    /// - Parameters:
    ///   - attStatus: `ATTrackingManager.AuthorizationStatus`
    @objc
    class func sendATTStatus(attStatus: ATTrackingManager.AuthorizationStatus) {
        shared.sendATTStatus(attStatus: attStatus)
    }

    /// KARTE SDKの機能に関連するカスタムURLスキームを処理します。
    ///
    /// なお初期化が行われていない状態で呼び出した場合はカスタムURLスキームの処理は行われません。
    ///
    /// - Parameters:
    ///   - app: `UIApplication` クラスインスタンス
    ///   - url: カスタムURLスキーム
    /// - Returns: カスタムURLスキームの処理結果を返します。SDKで処理が可能な場合は `true` を返し、処理できない場合は`false` を返します。
    @objc(application:openURL:)
    @discardableResult
    class func application(_ app: UIApplication, open url: URL) -> Bool {
        shared.application(app, open: url)
    }
}

public extension KarteApp {
    /// 登録されているモジュールの配列を返します。
    var modules: [Module] {
        moduleContainer.modules
    }

    /// ライブラリを登録します。
    ///
    /// なお登録処理は `KarteApp.setup(appKey:)` を呼び出す前に行う必要があります。
    ///
    /// - Parameter library: `Library` プロトコルに適合したクラスのタイプ
    class func register(library: Library.Type) {
        if !libraries.contains(where: { $0.name == library.name }) {
            libraries.append(library)
        }
    }

    /// ライブラリの登録を解除します。
    ///
    /// - Parameter library: `Library` プロトコルに適合したクラスのタイプ
    class func unregister(library: Library.Type) {
        libraries.removeAll { $0.name == library.name }
    }

    /// モジュールを登録します。
    ///
    /// - Parameter module: `Module` プロトコルに適合したインスタンス
    func register(module: Module) {
        moduleContainer.register(module)
    }

    /// モジュールの登録を解除します。
    ///
    /// - Parameter module: `Module` プロトコルに適合したインスタンス
    func unregister(module: Module) {
        moduleContainer.unregister(module)
    }

    /// ライブラリの設定を取得します。
    ///
    /// - 該当クラスが存在しない場合、`nil` を返します。
    /// - 該当クラスが複数存在する場合、最初の設定のみを返します。
    func libraryConfiguration<T: LibraryConfiguration>() -> T? {
        configuration.libraryConfigurations.compactMap { $0 as? T }.first
    }
}

public extension KarteApp {
    /// `KarteApp.setup(appKey:configuration:)` 呼び出し時に指定したアプリケーションキーを返します。
    ///
    /// 初期化が行われていない場合は空文字列を返します。
    var appKey: String {
        coreService?.configuration._appKey.value ?? ""
    }

    /// ビジターIDを返します。
    ///
    /// 初期化が行われていない場合は空文字列を返します。
    var visitorId: String {
        coreService?.visitorId ?? ""
    }

    /// `KarteApp.setup(appKey:configuration:)` 呼び出し時に指定した初期化オプションを返します。
    var configuration: Configuration {
        coreService?.configuration ?? Configuration.defaultConfiguration
    }

    /// オプトアウトの設定有無を返します。
    ///
    /// オプトアウトされている場合は `true` を返し、されていない場合は `false` を返します。<br>
    /// また初期化が行われていない場合は `false` を返します。
    var isOptOut: Bool {
        coreService?.isOptOut ?? false
    }

    /// アプリケーション情報を返します。
    ///
    /// なお初期化が行われていない場合は nil を返します。
    var appInfo: AppInfo? {
        coreService?.appInfo
    }

    /// `PvManagementService` インスタンスを返します。
    ///
    /// なお初期化が行われていない場合は nil を返します。
    var pvService: PvService? {
        coreService?.pvService
    }
}

extension KarteApp {
    func setup(configuration: Configuration) {
        let service = CoreService(configuration: configuration)
        guard service.isEnabled else {
            return
        }

        self.coreService = service
        self.trackingClient = TrackingClient(app: self, core: service)
        self.trackingClient?.delegate = Tracker.delegate
        self.trackingClient?.trackInitialEvents()

        Logger.info(tag: .core, message: "KARTE SDK initialize. appKey=\(appKey)")

        KarteApp.libraries.forEach { library in
            Logger.info(tag: .core, message: "Configure library. name=\(library.name)")
            library.configure(app: self)
        }
    }

    func teardown() {
        KarteApp.libraries.reversed().forEach { library in
            library.unconfigure(app: self)
        }

        self.trackingClient?.teardown()
        self.trackingClient = nil
        self.coreService?.teardown()
        self.coreService = nil
        Resolver.cached.reset()
    }

    func optIn() {
        coreService?.optIn()
    }

    func optOut() {
        coreService?.optOut()
    }

    func optOutTemporarily() {
        coreService?.optOutTemporarily()
    }

    func renewVisitorId() {
        coreService?.renewVisitorId()
    }

    func sendATTStatus(attStatus: ATTrackingManager.AuthorizationStatus) {
        coreService?.sendATTStatus(attStatus: attStatus)
    }

    func application(_ app: UIApplication, open url: URL) -> Bool {
        var handled = false
        for module in modules {
            if case let .deeplink(module) = module {
                if module.handle(app: app, open: url) {
                    handled = true
                }
            }
        }
        return handled
    }
}

extension Logger.Tag {
    static let core = Logger.Tag("CORE", version: KRTCoreCurrentLibraryVersion())
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerScreen()
        registerSystemInfo()
        registerAppInfo()
        registerVisitorIdService()
        registerVersionService()
        registerPvService()
        registerOptOutService()
        registerTrackClientSession()
        registerReachabilityService()
        registerApplicationStateProvider()
        registerConfiguration()
        registerIsReachable()
        registerExponentialBackoff()
        registerCircuitBreaker()
    }
}
