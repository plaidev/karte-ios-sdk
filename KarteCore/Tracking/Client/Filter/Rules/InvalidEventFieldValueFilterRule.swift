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

internal struct InvalidEventFieldValueFilterRule: EventFilterRule {
    func filter(_ event: Event) throws {
        switch event.eventName {
        case .view:
            guard let viewName = event.values.string(forKey: field(.viewName)) else {
                break
            }
            if viewName.isEmpty {
                Logger.error(tag: .track, message: "This view event is invalid. view_name is empty: \(event)")
                throw EventFilterError.invalidEventFieldValue
            }
        case .identify:
            guard let userId = event.values.string(forKey: field(.userId)) else {
                break
            }
            if userId.isEmpty {
                Logger.warn(tag: .track, message: "This identify event is invalid. user_id is empty: \(event)")
            }
        default:
            break
        }
    }
}
