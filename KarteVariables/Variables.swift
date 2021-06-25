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

/// 設定値の取得完了をハンドルするためのブロックの宣言です。
public typealias FetchCompletion = (_ isSuccessful: Bool) -> Void

/// 設定値の取得・管理を司るクラスです。
@objc(KRTVariables)
public class Variables: NSObject {
    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    /// 設定値を取得し、端末上にキャッシュします。
    /// - Parameter completion: 取得完了ハンドラ
    @objc
    public class func fetch(completion: FetchCompletion? = nil) {
        let task = Tracker.track(event: Event(.fetchVariables))
        task.completion = { isSuccessful in
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

    public func receive(response: TrackResponse.Response, request: TrackRequest) {
        if request.contains(eventName: .fetchVariables) {
            UserDefaults.standard.removeObject(forNamespace: .variables)
        }

        let messages = response.messages.compactMap { message -> VariableMessage? in
            VariableMessage.from(message: message)
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
                return [Variable(name: "unknown", campaignId: campaignId, shortenId: shortenId, value: nil)]
            }

            let inlinedVariables = action.content?.inlinedVariables ?? []
            let variables = inlinedVariables.compactMap { inlinedVariable -> Variable? in
                guard let name = inlinedVariable.name, let value = inlinedVariable.value else {
                    return nil
                }

                let variable = Variable(name: name, campaignId: campaignId, shortenId: shortenId, value: value)
                return variable
            }
            return variables
        }
        bulkSave(variables: variables)

        Tracker.track(variables: variables, type: .ready, values: [:])
    }

    public func reset(sceneId: SceneId) {
    }

    public func resetAll() {
    }

    public func renew(visitorId current: String, previous: String) {
        UserDefaults.standard.removeObject(forNamespace: .variables)
    }

    private func bulkSave(variables: [Variable]) {
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
