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

    public init(
        timestamp: Date,
        title: String,
        body: String,
        linkUrl: String,
        attachmentUrl: String,
        campaignId: String,
        messageId: String,
        isRead: Bool
    ) {
        self.timestamp = timestamp
        self.title = title
        self.body = body
        self.linkUrl = linkUrl
        self.attachmentUrl = attachmentUrl
        self.campaignId = campaignId
        self.messageId = messageId
        self.isRead = isRead
    }
}
