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

internal struct RemoteNotificationKey {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension RemoteNotificationKey {
    // swiftlint:disable operator_usage_whitespace
    static let push         = RemoteNotificationKey("krt_push_notification")
    static let massPush     = RemoteNotificationKey("krt_mass_push_notification")
    static let eventValues  = RemoteNotificationKey("krt_event_values")
    static let campaignId   = RemoteNotificationKey("krt_campaign_id")
    static let shortenId    = RemoteNotificationKey("krt_shorten_id")
    // swiftlint:enable operator_usage_whitespace
}
