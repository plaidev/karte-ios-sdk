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

/// イベント送信処理に割り込むためのモジュールタイプです。
///
/// **サブモジュールと連携するために用意している機能であり、通常利用で使用することはありません。**
public protocol TrackModule: ModuleBase {
    /// リクエスト処理に割り込みます。
    ///
    /// 編集済みのリクエストを返すことで、リクエスト内容を編集することが可能です。
    ///
    /// - Parameter urlRequest: リクエスト
    /// - Returns: 編集済みのリクエストを返します。
    func intercept(urlRequest: URLRequest) throws -> URLRequest

    /// イベントの送信拒絶フィルタルールのリストを返す。
    ///
    /// ここで返したルールリストに基づきイベントの送信を拒絶することが可能です。
    /// - Returns: フィルタリスト
    func provideEventRejectionFilterRules() -> [TrackEventRejectionFilterRule]
}

public extension TrackModule {
    // backward compatibility
    func provideEventRejectionFilterRules() -> [TrackEventRejectionFilterRule] {
        return []
    }
}
