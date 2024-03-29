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
    private let visitorId = "Dummy"
    private let config = DummyConfig()

    override func spec() {
        describe("a request") {
            describe("its init") {
                context("when initialized with parameters") {
                    it("has proper URL with ProductionConfig") {
                        let req = OpenMessagesRequest(visitorId: self.visitorId, messageIds: [], config: ProductionConfig())
                        expect(req.asURLRequest().url?.absoluteString).to(equal("https://api.karte.io/v2native/inbox/openMessages"))
                    }

                    it("has proper URL with EvaluationConfig") {
                        let req = OpenMessagesRequest(visitorId: self.visitorId, messageIds: [], config: EvaluationConfig())
                        expect(req.asURLRequest().url?.absoluteString).to(equal("https://api-evaluation.dev-karte.com/v2native/inbox/openMessages"))
                    }

                    it("has correspond visitorId in body") {
                        let req = OpenMessagesRequest(visitorId: self.visitorId, messageIds: [], config: self.config)
                        expect(req.bodyParams?["visitorId"] as? String).to(equal(self.visitorId))
                    }

                    it("has correspond messageIds in body") {
                        let targets = ["aaa", "bbb", "ccc"]
                        let req = OpenMessagesRequest(visitorId: self.visitorId, messageIds: targets, config: self.config)
                        expect(req.bodyParams?["messageIds"] as? [String]).to(equal(targets))
                    }
                }
            }
        }
    }
}
