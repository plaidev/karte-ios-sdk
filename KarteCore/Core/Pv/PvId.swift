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
import KarteUtilities

/// ページビューIDを保持する構造体です。
///
/// ページビューIDとは、アプリ内で画面遷移およびViewイベントの発火毎に発行されるIDのことです。
/// SDKではページビューIDを元に画面の境界を認識しています。
///
/// なおページビューIDは `UUID` クラスを利用して生成しております。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct PvId: Codable {
    /// ページビューID
    public var identifier: String = ""

    /// ページビューIDを生成します。
    public init(_ identifier: String) {
        self.identifier = identifier

        Logger.debug(tag: .core, message: "Generate PvId: \(identifier)")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.identifier = try container.decode(String.self)
    }

    public static func generate() -> PvId {
        let generator = Resolver.resolve(IdGenerator.self, name: "pv_service.generator")
        return PvId(generator.generate())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}

extension PvId: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
