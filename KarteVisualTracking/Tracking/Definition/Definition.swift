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
import KarteCore

internal struct Definition: Codable {
    struct DummyDecodable: Decodable {}

    var eventName: EventName
    var triggers: [Trigger]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventName = try container.decode(EventName.self, forKey: .eventName)
        var nestedUnkeyedContainer = try container.nestedUnkeyedContainer(forKey: .triggers)
        var tmpTriggers: [Trigger] = []
        while !nestedUnkeyedContainer.isAtEnd {
            do {
                let trigger = try nestedUnkeyedContainer.decode(Trigger.self)
                tmpTriggers.append(trigger)
            } catch {
                _ = try nestedUnkeyedContainer.decode(DummyDecodable.self)
            }
        }
        triggers = tmpTriggers
    }

    func events(data: [String: JSONValue]) -> [Event] {
        triggers.filter { trigger -> Bool in
            trigger.match(data: data)
        }.map { trigger -> Event in
            let values: [String: JSONConvertible] = trigger.fields
            let other: [String: JSONConvertible] = [
                "_system": [
                    "auto_track": 1
                ]
            ]
            return Event(
                eventName: eventName,
                values: values.merging(other) { $1 }
            )
        }
    }
}

extension Definition {
    enum CodingKeys: String, CodingKey {
        case eventName  = "event_name"
        case triggers
    }
}
