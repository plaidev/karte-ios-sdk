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
@testable import KarteInbox

final class FetchMessagesRequestSpec: QuickSpec {
    private let userId = "Dummy"

    override func spec() {
        describe("a request") {
            describe("its init") {
                context("when initialized with parameters") {
                    it("has correspond userId in body") {
                        let req = FetchMessagesRequest(userId: self.userId)
                        expect(req.bodyParams?["userId"] as? String).to(equal(self.userId))
                    }

                    it("has correspond limit in body") {
                        let req = FetchMessagesRequest(userId: self.userId, limit: 1)
                        expect(req.bodyParams?["limit"] as? UInt).to(equal(1))
                    }

                    it("has correspond latestMessageId in body") {
                        let dummy = "Dummy messageId"
                        let req = FetchMessagesRequest(userId: self.userId, latestMessageId: dummy)
                        expect(req.bodyParams?["latestMessageId"] as? String).to(equal(dummy))
                    }
                }

                context("when initialized without optional parameters") {
                    it("has nil for optional body parameters") {
                        let req = FetchMessagesRequest(userId: self.userId)
                        let limit = req.bodyParams?["limit"]
                        let latestMessageId = req.bodyParams?["latestMessageId"]
                        expect(limit).to(beNil())
                        expect(latestMessageId).to(beNil())
                    }
                }
            }
        }
    }
}
