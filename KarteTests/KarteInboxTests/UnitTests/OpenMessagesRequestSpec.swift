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

final class OpenMessagesRequestSpec: QuickSpec {
    private let userId = "Dummy"

    override func spec() {
        describe("a request") {
            describe("its init") {
                context("when initialized with parameters") {
                    it("has correspond userId in body") {
                        let req = OpenMessagesRequest(userId: self.userId, messageIds: [])
                        expect(req.bodyParams?["userId"] as? String).to(equal(self.userId))
                    }

                    it("has correspond messageIds in body") {
                        let targets = ["aaa", "bbb", "ccc"]
                        let req = OpenMessagesRequest(userId: self.userId, messageIds: targets)
                        expect(req.bodyParams?["messageIds"] as? [String]).to(equal(targets))
                    }
                }
            }
        }
    }
}
