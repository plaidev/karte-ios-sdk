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

public enum UserDefaultsNamespace: String {
    case `default`
    case variables
    case config
}

extension UserDefaults {
    /// 指定されたキーに関連付けて値を保存します。
    /// - Parameters:
    ///   - value: キーに関連付けて保存する値
    ///   - key: `UserDefaults` にアクセスするためのキー
    public func set(_ value: Any?, forKey key: UserDefaultsKey) {
        var root = loadRootObject(forNamespace: key.namespace)
        if let value = value {
            root[key.key] = value
        } else {
            root.removeValue(forKey: key.key)
        }
        saveRootObject(root, forNamespace: key.namespace)
    }

    /// 指定された `Dictionary` のキーと値を指定されたネームスペースに対してそれぞれ保存します。
    /// - Parameters:
    ///   - keyValue: 保存するキーと値を持った `Dictionary`
    ///   - namespace: 保存先のネームスペースキー
    public func bulkSet(_ keyValue: [String: Any?], forNameSpace namespace: UserDefaultsNamespace) {
        var root = loadRootObject(forNamespace: namespace)
        for (key, value) in keyValue {
            if let value = value {
                root[key] = value
            } else {
                root.removeValue(forKey: key)
            }
        }
        saveRootObject(root, forNamespace: namespace)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: `UserDefaults` を検索するためのキー
    /// - Returns: キーに関連付けられた値がある場合はそれを返し、ない場合は nil を返します。
    public func object(forKey key: UserDefaultsKey) -> Any? {
        let rootKey = makeRootKey(forNamespace: key.namespace)
        guard let root = object(forKey: rootKey) as? [String: Any] else {
            return nil
        }
        return root[key.key]
    }

    /// 指定されたネームスペースに関連付けられた全てのキーを取得します。
    /// - Parameter namespace: `UserDefaults` を検索するためのネームスペースキー
    /// - Returns: キーの一覧
    public func getAllKeys(forNamespace namespace: UserDefaultsNamespace) -> [String] {
        let root = loadRootObject(forNamespace: namespace)
        return [String](root.keys)
    }

    /// 指定されたキーに関連付けられた値の有無を確認します。
    /// - Parameter key: `UserDefaults` を検索するためのキー
    /// - Returns: キーに関連付けられた値がある場合は `true` を返し、ない場合は `false` を返します。
    public func contains(forKey key: UserDefaultsKey) -> Bool {
        object(forKey: key) != nil
    }

    /// 指定されたキーに関連付けられた値を削除します。
    /// - Parameter key: `UserDefaults` を検索するためのキー
    public func removeObject(forKey key: UserDefaultsKey) {
        set(nil, forKey: key)
    }

    /// 指定されたネームスペースに関連付けられた全ての値を削除します。
    /// - Parameter namespace: `UserDefaults` を検索するためのネームスペースキー
    public func removeObject(forNamespace namespace: UserDefaultsNamespace) {
        let rootKey = makeRootKey(forNamespace: namespace)
        removeObject(forKey: rootKey)
    }

    private func loadRootObject(forNamespace namespace: UserDefaultsNamespace) -> [String: Any] {
        let rootKey = makeRootKey(forNamespace: namespace)
        return object(forKey: rootKey) as? [String: Any] ?? [:]
    }

    // swiftlint:disable:next discouraged_optional_collection
    private func saveRootObject(_ value: [String: Any]?, forNamespace namespace: UserDefaultsNamespace) {
        let rootKey = makeRootKey(forNamespace: namespace)
        set(value, forKey: rootKey)
    }

    private func makeRootKey(forNamespace namespace: UserDefaultsNamespace) -> String {
        "io.karte.\(namespace.rawValue)"
    }
}
