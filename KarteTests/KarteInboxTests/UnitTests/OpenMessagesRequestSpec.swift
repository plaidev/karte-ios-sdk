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

import XCTest
@testable import KarteInbox

final class OpenMessagesRequestSpec: XCTestCase {
    private let visitorId = "Dummy"
    private let config = DummyConfig()

    func testHasProperURLWithProductionConfig() {
        let req = OpenMessagesRequest(visitorId: visitorId, messageIds: [], config: ProductionConfig())
        XCTAssertEqual(req.asURLRequest().url?.absoluteString, "https://api.karte.io/v2native/inbox/openMessages", "production URL")
    }

    func testHasProperURLWithEvaluationConfig() {
        let req = OpenMessagesRequest(visitorId: visitorId, messageIds: [], config: EvaluationConfig())
        XCTAssertEqual(req.asURLRequest().url?.absoluteString, "https://api-evaluation.dev-karte.com/v2native/inbox/openMessages", "evaluation URL")
    }

    func testHasCorrespondVisitorIdInBody() {
        let req = OpenMessagesRequest(visitorId: visitorId, messageIds: [], config: config)
        XCTAssertEqual(req.bodyParams?["visitorId"] as? String, visitorId, "visitorId in body")
    }

    func testHasCorrespondMessageIdsInBody() {
        let targets = ["aaa", "bbb", "ccc"]
        let req = OpenMessagesRequest(visitorId: visitorId, messageIds: targets, config: config)
        XCTAssertEqual(req.bodyParams?["messageIds"] as? [String], targets, "messageIds in body")
    }
}
