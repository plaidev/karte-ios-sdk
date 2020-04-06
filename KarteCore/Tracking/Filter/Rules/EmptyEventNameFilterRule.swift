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

internal enum EventFilterError: Error {
    case emptyEventName
    case initializationEvent
}

internal struct EmptyEventNameFilterRule: EventFilterRule {
    func filter(_ event: Event) throws {
        if event.eventName.rawValue.isEmpty {
            Logger.error(tag: .track, message: "Event name is empty.")
            throw EventFilterError.emptyEventName
        }
    }
}
