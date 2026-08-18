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

final class FetchMessagesRequestSpec: XCTestCase {
    private let visitorId = "Dummy"
    private let config = DummyConfig()

    func testHasProperURLWithProductionConfig() {
        let req = FetchMessagesRequest(visitorId: visitorId, config: ProductionConfig())
        XCTAssertEqual(req.asURLRequest().url?.absoluteString, "https://api.karte.io/v2native/inbox/fetchMessages", "production URL")
    }

    func testHasProperURLWithEvaluationConfig() {
        let req = FetchMessagesRequest(visitorId: visitorId, config: EvaluationConfig())
        XCTAssertEqual(req.asURLRequest().url?.absoluteString, "https://api-evaluation.dev-karte.com/v2native/inbox/fetchMessages", "evaluation URL")
    }

    func testHasCorrespondVisitorIdInBody() {
        let req = FetchMessagesRequest(visitorId: visitorId, config: config)
        XCTAssertEqual(req.bodyParams?["visitorId"] as? String, visitorId, "visitorId in body")
    }

    func testHasCorrespondLimitInBody() {
        let req = FetchMessagesRequest(visitorId: visitorId, limit: 1, config: config)
        XCTAssertEqual(req.bodyParams?["limit"] as? UInt, 1, "limit in body")
    }

    func testHasCorrespondLatestMessageIdInBody() {
        let dummy = "Dummy messageId"
        let req = FetchMessagesRequest(visitorId: visitorId, latestMessageId: dummy, config: config)
        XCTAssertEqual(req.bodyParams?["latestMessageId"] as? String, dummy, "latestMessageId in body")
    }

    func testHasNilForOptionalBodyParameters() {
        let req = FetchMessagesRequest(visitorId: visitorId, config: config)
        let limit = req.bodyParams?["limit"]
        let latestMessageId = req.bodyParams?["latestMessageId"]
        XCTAssertNil(limit, "limit")
        XCTAssertNil(latestMessageId, "latestMessageId")
    }
}
