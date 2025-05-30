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

internal struct TrackBodyParameters: BodyParameters, Codable {
    var appInfo: AppInfo
    var events: [Event]
    var keys: Keys

    var contentType: String {
        "application/json"
    }

    init(appInfo: AppInfo, events: [Event], keys: Keys) {
        self.appInfo = appInfo
        self.events = events
        self.keys = keys
    }

    func buildEntity() throws -> RequestBodyEntity {
        let data = try createJSONEncoder().encode(self)
        do {
            let gzippedData = try gzipped(data)
            return .data(gzippedData)
        } catch {
            Logger.verbose(tag: .track, message: "\(error)")
            return .data(data)
        }
    }
}

extension TrackBodyParameters {
    enum CodingKeys: String, CodingKey {
        case appInfo = "app_info"
        case events
        case keys
    }

    struct Keys: Codable {
        var visitorId: String?
        var pvId: PvId
        var originalPvId: PvId
    }
}

extension TrackBodyParameters.Keys {
    enum CodingKeys: String, CodingKey {
        case visitorId      = "visitor_id"
        case pvId           = "pv_id"
        case originalPvId   = "original_pv_id"
    }
}
