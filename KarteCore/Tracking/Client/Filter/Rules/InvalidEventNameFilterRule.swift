//
//  Copyright 2021 PLAID, Inc.
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

internal struct InvalidEventNameFilterRule: EventFilterRule {
    class Regex {
        static let shared = Regex()
        lazy var regex: NSRegularExpression? = try? NSRegularExpression(pattern: "[^a-z0-9_]", options: [])

        deinit {
        }

        func match(_ string: String) -> Bool {
            return regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) != nil
        }
    }

    func filter(_ event: Event) throws {
        if !event.eventName.isUserDefinedEvent {
            return
        }
        let eventName = event.eventName.rawValue
        if Regex.shared.match(eventName) {
            Logger.warn(tag: .track, message: "Event name can only use [a-z0-9_]: \(eventName)")
        }
        if eventName.hasPrefix("_") {
            Logger.warn(tag: .track, message: "Event name starting with _ cannot be used: \(eventName)")
        }
    }
}
