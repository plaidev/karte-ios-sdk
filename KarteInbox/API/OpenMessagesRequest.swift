//
//  Copyright 2023 PLAID, Inc.
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

struct OpenMessagesRequest: BaseAPIRequest {
    typealias Response = OpenMessagesResponse

    let userId: String
    let messageIds: [String]

    var method: HTTPMethod {
        .post
    }

    var path: String {
        "inbox/openMessages"
    }

    var bodyParams: [String: Any]? {
        let body: [String: Any] = [
            "userId": userId,
            "appType": "native_app",
            "os": "ios",
            "messageIds": messageIds
        ]
        return body
    }
}

struct OpenMessagesResponse: Decodable {
    let success: Bool
}
