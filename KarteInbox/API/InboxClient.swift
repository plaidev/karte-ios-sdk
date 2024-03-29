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

struct InboxClient {
    private static let config = ProductionConfig()

    private static func call<Request: BaseAPIRequest>(_ request: Request) async -> Request.Response? {
        if #available(iOS 15.0, *) {
            let caller = NativeAsyncCaller()
            return await caller(callee: request)
        } else {
            let caller = FallbackAsyncCaller()
            return await caller(callee: request)
        }
    }
}

extension InboxClient {
    static func fetchMessages(by visitorId: String, limit: UInt? = nil, latestMessageId: String? = nil) async -> [InboxMessage]? {
        let req = FetchMessagesRequest(visitorId: visitorId, limit: limit, latestMessageId: latestMessageId, config: config)
        let res = await call(req)
        return res?.messages
    }

    static func openMessages(for visitorId: String, messageIds: [String]) async -> Bool {
        let req = OpenMessagesRequest(visitorId: visitorId, messageIds: messageIds, config: config)
        let res = await call(req)
        return res?.success ?? false
    }
}
