//
//  Copyright 2022 PLAID, Inc.
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

/// Karte経由で送信したPush通知を表すタイプです。
public struct InboxMessage: Decodable {
    /// 送信された時間を返します。
    public let timestamp: Date

    /// Push通知のタイトルを返します。
    public let title: String

    /// Push通知の本文を返します。
    public let body: String

    /// Push通知に設定された遷移先リンクURLを返します。<br>
    /// 未設定の場合は空文字を返します。
    public let linkUrl: String

    /// Push通知に設定された画像URLを返します。<br>
    /// 未設定の場合は空文字を返します。
    public let attachmentUrl: String

    /// 接客のキャンペーンIDを返します。
    public let campaignId: String

    /// Push通知のユニークなIDを返します。
    public let messageId: String

    /// Push通知の既読状態を返します。
    public let isRead: Bool

    /// Push通知に設定されたカスタムペイロードを返します。
    public var customPayload: [String: Any?] {
        _customPayload.value
    }

    // swiftlint:disable:next identifier_name
    let _customPayload: CustomPayload

    // swiftlint:disable identifier_name
    public init(
        timestamp: Date,
        title: String,
        body: String,
        linkUrl: String,
        attachmentUrl: String,
        campaignId: String,
        messageId: String,
        isRead: Bool,
        _customPayload: CustomPayload
    ) {
        self.timestamp = timestamp
        self.title = title
        self.body = body
        self.linkUrl = linkUrl
        self.attachmentUrl = attachmentUrl
        self.campaignId = campaignId
        self.messageId = messageId
        self.isRead = isRead
        self._customPayload = _customPayload
    }

    enum CodingKeys: String, CodingKey {
        case timestamp, title, body, linkUrl, attachmentUrl, campaignId, messageId, isRead
        case _customPayload = "customPayload"
    }

    /// カスタムペイロードを表すタイプです。
    /// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
    public struct CustomPayload: Decodable {
        fileprivate var value: [String: Any?] = [:]

        struct CodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int?

            init(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue: Int) { return nil }
        }

        public init(from decoder: Decoder) throws {
            if let container = try? decoder.container(keyedBy: CodingKeys.self) {
                self.value = decode(fromObject: container)
            }
        }

        private func decode(fromObject container: KeyedDecodingContainer<CodingKeys>) -> [String: Any?] {
            var result: [String: Any?] = [:]

            for key in container.allKeys {
                if let val = try? container.decode(Int.self, forKey: key) {
                    result[key.stringValue] = val
                } else if let val = try? container.decode(UInt.self, forKey: key) {
                    result[key.stringValue] = val
                } else if let val = try? container.decode(Double.self, forKey: key) {
                    result[key.stringValue] = val
                } else if let val = try? container.decode(String.self, forKey: key) {
                    result[key.stringValue] = val
                } else if let val = try? container.decode(Bool.self, forKey: key) {
                    result[key.stringValue] = val
                } else if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: key) {
                    result[key.stringValue] = decode(fromObject: nestedContainer)
                } else if var nestedArray = try? container.nestedUnkeyedContainer(forKey: key) {
                    result[key.stringValue] = decode(fromArray: &nestedArray)
                } else if (try? container.decodeNil(forKey: key)) == true {
                    result.updateValue(nil, forKey: key.stringValue)
                }
            }
            return result
        }

        private func decode(fromArray container: inout UnkeyedDecodingContainer) -> [Any?] {
            var result: [Any?] = []

            while !container.isAtEnd {
                if let val = try? container.decode(String.self) {
                    result.append(val)
                } else if let value = try? container.decode(Int.self) {
                    result.append(value)
                } else if let val = try? container.decode(UInt.self) {
                    result.append(val)
                } else if let val = try? container.decode(Double.self) {
                    result.append(val)
                } else if let val = try? container.decode(Bool.self) {
                    result.append(val)
                } else if let nestedContainer = try? container.nestedContainer(keyedBy: CodingKeys.self) {
                    result.append(decode(fromObject: nestedContainer))
                } else if var nestedArray = try? container.nestedUnkeyedContainer() {
                    result.append(decode(fromArray: &nestedArray))
                } else if (try? container.decodeNil()) == true {
                    result.append(nil)
                }
            }
            return result
        }
    }
}
