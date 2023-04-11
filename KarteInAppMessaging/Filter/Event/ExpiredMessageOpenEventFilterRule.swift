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
import KarteCore

internal struct ExpiredMessageOpenEventRejectionFilterRule: TrackEventRejectionFilterRule {
    var interval: TimeInterval
    var dateResolver: () -> Date

    var libraryName: String {
        return InAppMessaging.name
    }

    var eventName: EventName {
        return .messageOpen
    }

    init(interval: TimeInterval = -180, dateResolver: @escaping () -> Date = { Date() }) {
        self.interval = interval
        self.dateResolver = dateResolver
    }

    func reject(event: Event) -> Bool {
        guard let responseTimestamp = event.values.string(forKeyPath: "message.response_timestamp") else {
            return false
        }
        guard let responseTimestampDate = iso8601DateTimeFormatter.date(from: responseTimestamp) else {
            return false
        }

        let difference = round(dateResolver().addingTimeInterval(interval).timeIntervalSince(responseTimestampDate))
        let invalid = difference > 0
        if invalid {
            Logger.info(tag: .inAppMessaging, message: "\(eventName) is invalid because it has expired. ts=\(responseTimestamp)")
        }
        return invalid
    }
}
