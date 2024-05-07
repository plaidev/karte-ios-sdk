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
import KarteCore
import KarteUtilities

/// 設定値の取得完了をハンドルするためのブロックの宣言です。
public typealias FetchCompletion = (_ isSuccessful: Bool) -> Void

/// 最終フェッチステータスを表す列挙型です。
@objc(KRTLastFetchStatus)
public enum LastFetchStatus: Int {
    /// nofetchYet
    case nofetchYet
    /// success
    case success
    /// failure
    case failure
}

/// 設定値の取得・管理を司るクラスです。
@objc(KRTVariables)
public class Variables: NSObject {
    private static let lastFetchTimeKey = "lastFetchTime"
    private static let lastFetchStatusKey = "lastFetchStatus"

    /// 最終フェッチ完了時間を返します、未フェッチな場合は `nil` を返します
    @objc public class var lastFetchTime: Date? {
        if let date = UserDefaults.standard.object(forKey: .lastFetchTime) as? Date {
            return date
        }
        return nil
    }

    /// 最終フェッチ完了ステータスを返します
    @objc public class var lastFetchStatus: LastFetchStatus {
        if let optionalStatus = UserDefaults.standard.object(forKey: .lastFetchStatus) as? Int,
           let status = LastFetchStatus(rawValue: optionalStatus) {
            return status
        }
        return .nofetchYet
    }

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    /// 直近指定秒以内に成功したフェッチ結果があるかどうかを返します
    /// - Parameter inSeconds: 秒数（1以上）
    @objc
    public class func hasSuccessfulLastFetch(inSeconds: TimeInterval) -> Bool {
        guard let lastFetchTime = Variables.lastFetchTime,
              Variables.lastFetchStatus == .success,
              inSeconds > 0 else {
            return false
        }
        let nowMinusInSeconds = Date(timeIntervalSinceNow: -inSeconds)
        return nowMinusInSeconds < lastFetchTime
    }

    /// 設定値を取得し、端末上にキャッシュします。
    /// - Parameter completion: 取得完了ハンドラ
    @objc
    public class func fetch(completion: FetchCompletion? = nil) {
        let task = Tracker.track(event: Event(.fetchVariables))
        task.completion = { isSuccessful in
            saveLastFetchInfo(isSuccessful)
            completion?(isSuccessful)
        }
    }

    /// 指定されたキーに関連付けられた設定値にアクセスします。<br>
    /// なお設定値にアクセスするには事前に `Variables.fetch(completion:)` を呼び出しておく必要があります。
    ///
    /// - Parameter key: 検索するためのキー
    /// - Returns: キーに関連付けられた設定値を返します。
    @objc
    public class func variable(forKey key: String) -> Variable {
        Variable(name: key)
    }

    /// 全ての設定値のキーの一覧を取得します。<br>
    /// なお事前に `Variables.fetch(completion:)` を呼び出しておく必要があります。
    ///
    /// - Returns: 全ての設定値のキーの一覧を返します。
    @objc
    public class func getAllKeys() -> [String] {
        return UserDefaults.standard.getAllKeys(forNamespace: .variables).filter {
            // こちらの２つはシステムで利用している値なので除外する
            !["lastFetchTime", "lastFetchStatus"].contains($0)
        }
    }

    /// キーに特定の文字列を持つVariableのリスト取得します。<br>
    /// なお事前に `Variables.fetch(completion:)` を呼び出しておく必要があります。
    ///
    /// - Parameter forPredicate: キーマッチ用のブロック
    /// - Returns: マッチしたRegexの一覧を返します。
    @objc
    public class func filter(usingPredicate predicate: (String) -> Bool) -> [Variable] {
        let allKeys = Variables.getAllKeys()
        let filteredKeys = allKeys.filter(predicate)
        return filteredKeys.map { Variable(name: $0) }
    }

    /// 指定した設定値のキーのキャッシュを削除します<br>
    ///
    /// - Parameter key: 検索するためのキー
    @objc
    public class func clearCache(forKey key: String) {
        return UserDefaults.standard.removeObject(forKey: UserDefaultsKey(key, forNamespace: .variables))
    }

    /// 全ての設定値のキーのキャッシュを削除します<br>
    @objc
    public class func clearCacheAll() {
        return UserDefaults.standard.removeObject(forNamespace: .variables)
    }

    deinit {
    }
}

extension Variables: Library {
    public static var name: String {
        "variables"
    }

    public static var version: String {
        KRTVariablesCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        app.register(module: .action(Variables()))
        app.register(module: .user(Variables()))
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .action(Variables()))
        app.unregister(module: .user(Variables()))
    }
}

extension Variables: ActionModule, UserModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public var queue: DispatchQueue? {
        nil
    }

    public func receive(response: [String: JSONValue], request: TrackRequest) {
        if request.contains(eventName: .fetchVariables) {
            UserDefaults.standard.removeObject(forNamespace: .variables)
        }

        let messages = (response.jsonArray(forKey: "messages") ?? []).dictionaries.compactMap { message -> VariableMessage? in
            return VariableMessage.from(message: message)
        }.filter { message -> Bool in
            message.isEnabled
        }.reversed()

        let variables = messages.flatMap { message -> [Variable] in
            let campaign = message.campaign
            let action = message.action
            guard let campaignId = campaign.campaignId, let shortenId = action.shortenId else {
                return []
            }

            guard !message.isControlGroup else {
                return []
            }

            let inlinedVariables = action.content?.inlinedVariables ?? []
            let variables = inlinedVariables.compactMap { inlinedVariable -> Variable? in
                guard let name = inlinedVariable.name, let value = inlinedVariable.value else {
                    return nil
                }

                let variable = Variable(
                    name: name,
                    campaignId: campaignId,
                    shortenId: shortenId,
                    value: value,
                    timestamp: message.action.responseTimestamp,
                    eventHash: message.trigger.eventHashes
                )
                return variable
            }
            return variables
        }
        Variables.bulkSave(variables: variables)

        Tracker.trackReady(messages: Array(messages))
    }

    public func reset(sceneId: SceneId) {
    }

    public func resetAll() {
    }

    public func renew(visitorId current: String, previous: String) {
        UserDefaults.standard.removeObject(forNamespace: .variables)
    }
}

extension Variables {
    private class func saveLastFetchInfo(_ isSuccessful: Bool) {
        if isSuccessful {
            let keyValue: [String: Any] = [
                lastFetchTimeKey: Date(),
                lastFetchStatusKey: LastFetchStatus.success.rawValue
            ]
            UserDefaults.standard.bulkSet(keyValue, forNameSpace: .variables)
        } else {
            let keyValue: [String: Any] = [
                lastFetchTimeKey: Date(),
                lastFetchStatusKey: LastFetchStatus.failure.rawValue
            ]
            UserDefaults.standard.bulkSet(keyValue, forNameSpace: .variables)
        }
    }

    class func bulkSave(variables: [Variable]) {
        let keyValue = variables.filter { $0.campaignId != nil && $0.shortenId != nil }.reduce(into: [String: Any?]()) { dict, variable in
            do {
                let data = try JSONEncoder().encode(variable)
                dict[variable.name] = data
            } catch {
                Logger.verbose(tag: .variables, message: "Failed to encode JSON. \(error)")
            }
        }
        UserDefaults.standard.bulkSet(keyValue, forNameSpace: .variables)
    }
}

extension Logger.Tag {
    static let variables = Logger.Tag("VAR", version: KRTVariablesCurrentLibraryVersion())
}
