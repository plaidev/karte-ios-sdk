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

internal struct MessageFilter {
    class Builder {
        private var rules: [MessageFilterRule] = []

        deinit {
        }

        func add(_ rule: MessageFilterRule) -> Builder {
            rules.append(rule)
            return self
        }

        func build() -> MessageFilter {
            MessageFilter(rules)
        }
    }

    private let rules: [MessageFilterRule]

    private init(_ rules: [MessageFilterRule]) {
        self.rules = rules
    }

    func filter(_ messages: [TrackResponse.Response.Message], exclude: ((TrackResponse.Response.Message, String) -> Void)? = nil) -> [TrackResponse.Response.Message] {
        let messages = rules.reduce(messages) { messages, rule -> [TrackResponse.Response.Message] in
            messages.filter { message -> Bool in
                switch rule.filter(message) {
                case .include:
                    return true

                case .exclude(let reason):
                    exclude?(message, reason)
                    return false
                }
            }
        }
        return messages
    }
}

internal enum MessageFilterResult {
    case include
    case exclude(String)
}
