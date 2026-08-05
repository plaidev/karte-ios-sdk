//
//  Copyright 2026 PLAID, Inc.
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

import XCTest
@testable import KarteCore
@testable import KarteInAppMessaging

class MessageSuppressionFilterRuleSpec: XCTestCase {
    private func makeMessage(
        campaignId: String = "campaign-id",
        shortenId: String = "shorten-id"
    ) -> [String: JSONValue] {
        [
            "action": .dictionary([
                "campaign_id": .string(campaignId),
                "shorten_id": .string(shortenId),
                "_id": .string("action-id")
            ]),
            "campaign": .dictionary([
                "_id": .string(campaignId),
                "service_action_type": .string("banner")
            ])
        ]
    }

    func test_excludesMessagesWithSuppressModeReason() {
        let filter = MessageFilter.Builder()
            .add(MessageSuppressionFilterRule(isSuppressed: true))
            .build()

        var suppressedReason: String?
        let messages = filter.filter([makeMessage()]) { _, reason in
            suppressedReason = reason
        }

        XCTAssertTrue(messages.isEmpty)
        XCTAssertEqual(suppressedReason, "The display is suppressed by suppress mode.")
    }

    func test_includesMessagesWhenNotSuppressed() {
        let filter = MessageFilter.Builder()
            .add(MessageSuppressionFilterRule(isSuppressed: false))
            .build()

        var excludeCallCount = 0
        let messages = filter.filter([makeMessage()]) { _, _ in
            excludeCallCount += 1
        }

        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(excludeCallCount, 0)
    }
}
