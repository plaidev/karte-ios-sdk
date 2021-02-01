//
//  Copyright 2021 PLAID, Inc.
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
import UIKit

/// 基本となるアクション（操作ログ）の性質を表現する型です。
public protocol ActionProtocol {
    /// Action名を返します
    var action: String { get }

    /// ActionIDを返します
    var actionId: String? { get }

    /// ターゲット文字列を返します
    var targetText: String? { get }

    /// 画面名を返します
    var screenName: String? { get }

    /// 画面をホストするクラス名を返します
    var screenHostName: String? { get }

    /// 操作ログに添付する画像を返す関数（ペアリング時の操作ログ送信でのみ利用されます。）
    ///
    /// - Returns: 操作ログに添付する画像
    func image() -> UIImage?
}
