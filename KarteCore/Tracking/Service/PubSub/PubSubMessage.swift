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

internal struct PubSubMessage {
    var messageId: PubSubMessageId
    var publisherId: PubSubPublisherId
    var isReadyOnBackground: Bool
    var isRetryable: Bool
    var data: Data
    var createdAt: Date
    var updatedAt: Date

    var exponentialBackoff = ExponentialBackoff(interval: 0.5, randomFactor: 0, multiplier: 4, maxCount: 6)

    static func from(_ row: [String: SQLiteValue?]) -> PubSubMessage? {
        guard let messageId = row["message_id"] as? String else {
            return nil
        }
        guard let publisherId = row["publisher_id"] as? String else {
            return nil
        }
        guard let isReadyOnBackground = row["is_ready_on_background"] as? Int64 else {
            return nil
        }
        guard let data = row["data"] as? Data else {
            return nil
        }
        guard let createdAt = row["created_at"] as? TimeInterval else {
            return nil
        }
        guard let updatedAt = row["updated_at"] as? TimeInterval else {
            return nil
        }

        return PubSubMessage(
            messageId: PubSubMessageId(messageId),
            publisherId: PubSubPublisherId(publisherId),
            isReadyOnBackground: isReadyOnBackground != 0,
            isRetryable: true,
            data: data,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
    }
}

internal protocol PubSubMessageConvertible {
    var pubSubMessage: PubSubMessage { get }
}

internal struct PubSubMessageId: Hashable {
    var id: String

    init() {
        self.id = UUID().uuidString
    }

    init(_ id: String) {
        self.id = id
    }
}
