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

/// ライブラリを表すタイプです。
///
/// **サブモジュールと連携するために用意している機能であり、通常利用で使用することはありません。**
public protocol Library {
    /// ライブラリ名
    static var name: String { get }

    /// バージョン
    static var version: String { get }

    /// 公開モジュールであるかどうか
    static var isPublic: Bool { get }

    /// ライブラリを初期化します。
    /// - Parameter app: 初期化済みの `KarteApp` インスタンス
    static func configure(app: KarteApp)

    /// ライブラリを破棄します。
    /// - Parameter app: 初期化済みの `KarteApp` インスタンス
    static func unconfigure(app: KarteApp)
}
