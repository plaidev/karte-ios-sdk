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

/// 各モジュールタイプを一つの型で扱うための列挙型です。
///
/// **サブモジュールと連携するために用意している機能であり、通常利用で使用することはありません。**
public enum Module: Equatable {
    /// アクションモジュール
    case action(ActionModule)
    /// ユーザーモジュール
    case user(UserModule)
    /// 通知モジュール
    case notification(NotificationModule)
    /// ディープリンクモジュール
    case deeplink(DeepLinkModule)
    /// トラックモジュール
    case track(TrackModule)

    var type: String {
        switch self {
        case .action:
            return "action"
        case .user:
            return "user"
        case .notification:
            return "notification"
        case .deeplink:
            return "deeplink"
        case .track:
            return "track"
        }
    }

    var name: String {
        let module: ModuleBase
        switch self {
        case .action(let mod):
            module = mod

        case .user(let mod):
            module = mod

        case .notification(let mod):
            module = mod

        case .deeplink(let mod):
            module = mod

        case .track(let mod):
            module = mod
        }
        return module.name
    }

    public static func == (lhs: Module, rhs: Module) -> Bool {
        switch (lhs, rhs) {
        case let (.action(mod1), .action(mod2)):
            return mod1.name == mod2.name

        case let (.user(mod1), .user(mod2)):
            return mod1.name == mod2.name

        case let (.notification(mod1), .notification(mod2)):
            return mod1.name == mod2.name

        case let (.deeplink(mod1), .deeplink(mod2)):
            return mod1.name == mod2.name

        case let (.track(mod1), .track(mod2)):
            return mod1.name == mod2.name

        default:
            return false
        }
    }
}
