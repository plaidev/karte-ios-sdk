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

/// コマンドを表現するタイプです。
public protocol Command {
    /// URLを検証します。
    ///
    /// - Parameter url: 検証対象のURL
    /// - Returns: 有効なコマンドの場合はtrue、それ以外はfalseを返します。
    func validate(_ url: URL) -> Bool

    /// コマンドを実行します。
    func execute()
}

public extension Command {
    /// コマンドを実行します。
    /// - Parameter url: コマンドを表現するURL
    /// - Returns: コマンドを実行できた場合にtrue、それ以外はfalseを返します。
    func run(url: URL) -> Bool {
        if validateKarteScheme(url.scheme) && validate(url) {
            execute()
            return true
        }
        return false
    }

    /// URLスキームを検証します。
    ///
    /// - Parameter targetScheme: 検証対象のスキーム
    /// - Returns: 有効なスキームならtrue、それ以外はfalseを返します。
    func validateKarteScheme(_ targetScheme: String?) -> Bool {
        // 36はkrt-{apikey}の文字数
        guard let targetScheme = targetScheme,
            targetScheme.hasPrefix("krt-"),
            targetScheme.count == 36 else {
                return false
        }
        return true
    }
}
