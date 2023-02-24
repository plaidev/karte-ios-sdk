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

import Quick
import Nimble
@testable import KarteUtilities
@testable import KarteCore
@testable import KarteInAppMessaging

class ExpiredMessageOpenEventRejectionFilterRuleSpec: QuickSpec {
    override func spec() {
        var now: Date!
        var rule: ExpiredMessageOpenEventRejectionFilterRule!

        func runTest(type: Event.MessageType, responseTimestamp: Date) -> Bool {
            let event = Event(.message(type: type, campaignId: "cid", shortenId: "sid", values: [
                "message": [
                    "response_timestamp": iso8601DateTimeFormatter.string(from: responseTimestamp)
                ]
            ]))
            return rule.reject(event: event)
        }
        
        beforeSuite {
            now = Date()
            rule = ExpiredMessageOpenEventRejectionFilterRule(interval: -180) {
                return now
            }
        }
        
        describe("expired check") {
            context("expired - 181 seconds elapsed") {
                it("be true") {
                    let flag = runTest(type: .open, responseTimestamp: now.addingTimeInterval(-181))
                    expect(flag).to(beTrue())
                }
            }
            
            context("not expired - 180 seconds elapsed") {
                it("be false") {
                    let flag = runTest(type: .open, responseTimestamp: now.addingTimeInterval(-180))
                    expect(flag).to(beFalse())
                }
            }
        }
    }
}
