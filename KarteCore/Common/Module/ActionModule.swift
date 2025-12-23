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

/// アクションに関連する処理をフックするためのモジュールタイプです。
///
/// **サブモジュールと連携するために用意している機能であり、通常利用で使用することはありません。**
public protocol ActionModule: ModuleBase {
    /// `ActionModule.receive(response:request:)` を呼び出す際に利用する `DispatchQueue` を返します。
    /// `nil` を返した場合は、カレントスレッドでメソッドを呼び出します。
    var queue: DispatchQueue? { get }

    // TODO: To be removed in the next major version. (backward compatibility)
    // swiftlint:disable:previous todo
    /// Trackサーバーのレスポンスデータをハンドルします. (deprecated)
    ///
    /// - Parameters:
    ///   - response: レスポンス
    ///   - request: リクエスト
    func receive(response: TrackResponse.Response, request: TrackRequest)

    /// Trackサーバーのレスポンスデータをハンドルします。
    ///
    /// - Parameters:
    ///   - response: レスポンス
    ///   - request: リクエスト
    func receive(response: [String: JSONValue], request: TrackRequest)

    /// 特定のシーンで発生したリセット要求をハンドルします。
    /// - Parameter sceneId: シーンID
    func reset(sceneId: SceneId)

    /// リセット要求をハンドルします。
    func resetAll()
}

public extension ActionModule {
    // TODO: To be removed in the next major version. (backward compatibility)
    // swiftlint:disable:previous todo
    func receive(response: TrackResponse.Response, request: TrackRequest) {
        // NOP
    }

    func receive(response: [String: JSONValue], request: TrackRequest) {
        // NOP
    }
}
