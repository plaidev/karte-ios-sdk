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

import UIKit

/// `PvId` をキーに関連付けて管理するための構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
internal struct PvIdBucket {
    private var bucket: [SceneId: PvId] = [:]

    /// 指定された `PvId` を同じく指定されたキーに関連付けて保持します。
    /// - Parameters:
    ///   - pvId: `PvId`
    ///   - key: 関連付けに使用するキー
    mutating func set(_ pvId: PvId, forKey key: SceneId) {
        bucket[key] = pvId
    }

    /// 指定されたキーに関連付けられた `PvId` にアクセスします。
    /// - Parameter key: 検索に使用するキー
    /// - Returns: 指定されたキーに関連付けられた `PvId` がある場合はそれを返し、ない場合は nil を返します。
    func pvId(forKey key: SceneId) -> PvId? {
        bucket[key]
    }
}
