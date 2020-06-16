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
import UIKit

/// シーンIDを保持する構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct SceneId: Codable, Hashable {
    private static let identifierForDefault = "DEFAULT"

    /// デフォルトのシーンIDを返します。
    public static var `default`: SceneId {
        SceneId(identifierForDefault)
    }

    /// シーンID
    public var identifier: String

    /// シーンに関連するWindowの配列を返します。
    public var windows: [UIWindow] {
        WindowDetector.retrieveRelatedWindows(from: identifier)
    }

    /// シーンIDを生成します。
    ///
    /// - Parameter view: `UIVew`
    public init(view: UIView?) {
        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view) ?? SceneId.default.identifier
        self.identifier = identifier
    }

    /// シーンIDを生成します。
    ///
    /// - Parameter identifier: シーンID
    public init(_ identifier: String?) {
        self.identifier = identifier ?? SceneId.default.identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.identifier = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}
