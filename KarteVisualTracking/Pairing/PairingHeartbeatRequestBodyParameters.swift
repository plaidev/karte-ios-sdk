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

internal struct PairingHeartbeatRequestBodyParameters: BodyParameters, Codable {
    var os: String
    var visitorId: String

    var contentType: String {
        "application/json"
    }

    init(visitorId: String) {
        self.os = "iOS"
        self.visitorId = visitorId
    }

    func buildEntity() throws -> RequestBodyEntity {
        let body = try createJSONEncoder().encode(self)
        return .data(body)
    }
}

extension PairingHeartbeatRequestBodyParameters {
    enum CodingKeys: String, CodingKey {
        case os
        case visitorId  = "visitor_id"
    }
}
