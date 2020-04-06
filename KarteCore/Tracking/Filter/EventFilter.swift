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

internal struct EventFilter {
    class Builder {
        var rules: [EventFilterRule] = []

        deinit {
        }

        func add(_ rule: EventFilterRule, isEnabled: Bool = true) -> Builder {
            if isEnabled {
                rules.append(rule)
            }
            return self
        }

        func build() -> EventFilter {
            EventFilter(rules)
        }
    }

    private let rules: [EventFilterRule]

    private init(_ rules: [EventFilterRule]) {
        self.rules = rules
    }

    func filter(_ event: Event) throws {
        try rules.forEach { try $0.filter(event) }
    }
}
