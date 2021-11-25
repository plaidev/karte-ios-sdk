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

internal struct InvalidEventFieldNameFilterRule: EventFilterRule {
    static let invalidFieldNames: [String] = ["_source", "_system", "any", "avg", "cache", "count", "count_sets", "date", "f_t", "first", "keys", "l_t", "last", "lrus", "max", "min", "o", "prev", "sets", "size", "span", "sum", "type", "v"]

    func filter(_ event: Event) throws {
        let invalidValues = event.values.filter({ (key, _) in
            key.contains(".") || key.hasPrefix("$") || InvalidEventFieldNameFilterRule.invalidFieldNames.contains(key)
        })
        if !invalidValues.isEmpty {
            Logger.warn(tag: .track, message: "Contains dots(.) or stating with $ or \(InvalidEventFieldNameFilterRule.invalidFieldNames) in event field name is deprecated: EventName=\(event.eventName.rawValue),FieldName=\(invalidValues)")
        }
    }
}
