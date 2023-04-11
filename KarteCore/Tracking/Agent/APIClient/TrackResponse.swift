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

/// Track API のレスポンス情報を保持する構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct TrackResponse: Codable {
    /// リクエスト成否
    public var success: Int
    /// ステータス
    public var status: Int
    /// レスポンス
    public var response: [String: JSONValue]?
    /// エラー
    public var error: String?
}

// TODO: To be removed in the next major version. (backward compatibility)
// swiftlint:disable:previous todo
public extension TrackResponse {
    /// レスポンス情報を保持する構造体です (deprecated)
    ///
    /// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
    struct Response: Codable {
        /// ステータス
        public var status: Int
        /// レスポンスに関連するイベントの配列
        public var events: [Event]
        /// 接客サービスの一覧
        public var messages: [Message]
        /// オプション
        public var options: [String: JSONValue]

        /// ビジュアルトラッキングの定義情報
        public var autoTrackDefinition: [String: JSONValue]?
        // swiftlint:disable:previous discouraged_optional_collection
        static var emptyResponse: Response {
            Response(status: 200, events: [], messages: [], options: [:])
        }

        static func convert(_ dict: [String: JSONValue]) -> Response? {
            guard let data = try? createJSONEncoder().encode(dict) else {
                Logger.error(tag: .core, message: "Failed to construct JSON.")
                return nil
            }
            guard let response = try? createJSONDecoder().decode(self, from: data) else {
                Logger.error(tag: .core, message: "Failed to construct Response.")
                return nil
            }
            return response
        }

        /// レスポンス情報をbase64エンコードした文字列を返します。
        public var base64EncodedString: String? {
            guard let data = try? createJSONEncoder().encode(self) else {
                Logger.error(tag: .core, message: "Failed to construct JSON.")
                return nil
            }
            return data.base64EncodedString(options: .endLineWithLineFeed)
        }
    }
}

public extension TrackResponse.Response {
    enum CodingKeys: String, CodingKey {
        case status
        case events
        case messages
        case options
        case autoTrackDefinition = "auto_track_definition"
    }

    /// イベント情報を保持する構造体です。
    struct Event: Codable {
        /// イベント名
        public var eventName: String
        /// イベントハッシュ
        public var eventHash: String
        /// イベントに紐付けるカスタムオブジェクト
        public var values: [String: JSONValue]
    }

    /// 接客サービス関連の情報を保持する構造体です。
    struct Message: Codable {
        /// アクション情報
        public var action: [String: JSONValue]
        /// キャンペーン情報
        public var campaign: [String: JSONValue]
        /// トリガー情報
        public var trigger: [String: JSONValue]
    }
}

extension TrackResponse.Response.Event {
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case eventHash = "event_hash"
        case values
    }
}
