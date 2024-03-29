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

/// この構造体は、UserDefaultsのキーを表します。
public struct UserDefaultsKey {
    /// ネームスペース
    public let namespace: UserDefaultsNamespace

    /// ネームスペース中のキー
    public let key: String

    /// キーを生成します。
    /// - Parameters:
    ///   - key: キー
    ///   - namespace: ネームスペース
    public init(_ key: String, forNamespace namespace: UserDefaultsNamespace) {
        self.key = key
        self.namespace = namespace
    }
}

public extension UserDefaultsKey {
    /// オプトアウト情報
    static let optout = UserDefaultsKey("optout", forNamespace: .config)
    /// 最終フェッチ時間
    static let lastFetchTime = UserDefaultsKey("lastFetchTime", forNamespace: .variables)
    /// 最終フェッチステータス
    static let lastFetchStatus = UserDefaultsKey("lastFetchStatus", forNamespace: .variables)
}
