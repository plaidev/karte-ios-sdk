//
//  Copyright 2023 PLAID, Inc.
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

/// イベントの送信拒絶フィルタルールを定義するためのプロトコル。
public protocol TrackEventRejectionFilterRule {
    /// 送信拒絶対象イベントの発火元ライブラリ名
    var libraryName: String { get }

    /// 送信拒絶対象イベントのイベント名
    var eventName: EventName { get }

    /// イベントのフィルタリングを行う
    ///
    /// - Parameter event: イベント
    /// - Returns: イベントを送信対象から除外する場合は `true` を返す
    func reject(event: Event) -> Bool
}
