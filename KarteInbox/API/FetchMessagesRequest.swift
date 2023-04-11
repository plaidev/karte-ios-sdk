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
import KarteUtilities

struct FetchMessagesRequest: BaseAPIRequest {
    typealias Response = FetchMessagesResponse

    let visitorId: String
    let limit: UInt?
    let latestMessageId: String?
    let config: InboxConfig

    init(visitorId: String, limit: UInt? = nil, latestMessageId: String? = nil, config: InboxConfig) {
        self.visitorId = visitorId
        self.limit = limit
        self.latestMessageId = latestMessageId
        self.config = config
    }

    var method: HTTPMethod {
        .post
    }

    var path: String {
        "inbox/fetchMessages"
    }

    var bodyParams: [String: Any]? {
        var body: [String: Any] = [
            "visitorId": visitorId,
            "appType": "native_app",
            "os": "ios"
        ]
        if let limit = limit {
            body["limit"] = limit
        }
        if let latest = latestMessageId {
            body["latestMessageId"] = latest
        }
        return body
    }
}

struct FetchMessagesResponse: Decodable {
    let messages: [InboxMessage]
}
