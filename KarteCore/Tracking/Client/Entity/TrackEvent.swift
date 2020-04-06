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

internal struct TrackEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case values
    }

    var eventName: EventName
    var values: [String: JSONValue]

    init(eventName: EventName, values: [String: JSONValue], date: Date, isRetry: Bool) {
        self.eventName = eventName

        var other: [String: JSONConvertible] = [
            field(.localEventDate): date
        ]
        if isRetry {
            other[field(.retry)] = isRetry
        }
        self.values = values
            .merging(other.mapValues { $0.jsonValue }) { $1 }
    }

    func value(forFieldName name: EventFieldName) -> Any? {
        values[name.rawValue]?.rawValue
    }
}
