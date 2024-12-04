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
import Quick
import Nimble
import Mockingjay
@testable import KarteInbox

final class InboxSpec: XCTestCase {
    func test_fetchMessagesShouldBeParsedWithoutError() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success).build()
        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), successResponse)
        guard let res = await Inbox.fetchMessages() else {
            XCTFail("Should never be executed")
            return
        }

        expect(res.count).to(equal(2))
        expect(res[0].title).to(equal("title1"))
        expect(res[0].body).to(equal("body1"))
        expect(res[0].campaignId).to(equal("dummy_campaignId_1"))
        expect(res[0].messageId).to(equal("dummy_messageId_1"))
        expect(res[0].timestamp).notTo(beNil())
        expect(res[0].attachmentUrl).to(beEmpty())
        expect(res[0].linkUrl).to(beEmpty())
        expect(res[0].isRead).to(beTrue())

        expect(res[1].title).to(equal("title2"))
        expect(res[1].body).to(equal("body2"))
        expect(res[1].campaignId).to(equal("dummy_campaignId_2"))
        expect(res[1].messageId).to(equal("dummy_messageId_2"))
        expect(res[1].timestamp).notTo(beNil())
        expect(res[1].attachmentUrl).to(beEmpty())
        expect(res[1].linkUrl).to(beEmpty())
        expect(res[1].isRead).to(beFalse())
    }

    func test_customPayloadShouldBeParsedProperly() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success).build()
        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), successResponse)
        guard let res = await Inbox.fetchMessages(), res.count == 2 else {
            XCTFail("Should never be executed")
            return
        }
        
        let m1 = res[0]
        expect(m1.customPayload["keyStr"] as? String).to(equal("Dummy"))
        expect(m1.customPayload["keyInt"] as? Int).to(equal(10))
        expect(m1.customPayload["keyDouble"] as? Double).to(equal(1.11))
        expect(m1.customPayload["keyArray"] as? Array).to(equal([1, 2, 3]))
        expect(m1.customPayload["keyNull"]).to(beNil())
        
        guard let nestedMap = res[0].customPayload["keyMap"] as? Dictionary<String, Any> else {
            XCTFail("Should never be executed: nestedMap in customPayload must be parsed: \(m1.customPayload)")
            return
        }
        expect(nestedMap["prop1"] as? String).to(equal("hoge"))
        expect(nestedMap["prop2"] as? Int).to(equal(0))

        let m2 = res[1]
        expect(m2.customPayload.count).to(equal(0))
    }

    func test_fetchMessagesShouldReturnNilWith400Errors() async throws {
        let badResponse400 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 400)
        let badResponse401 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 401)
        let badResponse403 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 403)
        let badResponse404 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 404)

        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), badResponse400)
        let res1 = await Inbox.fetchMessages()
        expect(res1).to(beNil())

        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), badResponse401)
        let res2 = await Inbox.fetchMessages()
        expect(res2).to(beNil())

        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), badResponse403)
        let res3 = await Inbox.fetchMessages()
        expect(res3).to(beNil())

        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), badResponse404)
        let res4 = await Inbox.fetchMessages()
        expect(res4).to(beNil())
    }

    func test_fetchMessagesShouldReturnNilwith500Error() async throws {
        let badResponse500 = StubBuilder(test: self, resource: .failure_server_error).build()
        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), badResponse500)
        let res = await Inbox.fetchMessages()
        expect(res).to(beNil())
    }

    func test_fetchMessagesShouldReturnNilWithInvalidData() async {
        let badResponse = """
        {
            "messages": [
                { "wrong_key": "invalid value" }
            ]
        }
        """.data(using: .utf8)!
        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), jsonData(badResponse))
        let res = await Inbox.fetchMessages()
        expect(res).to(beNil())
    }

    func test_openMessagesShouldReturnTrueIfResponseIsSuccess() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success_empty).build()
        stub(http(.post, uri: "/v2native/inbox/openMessages"), successResponse)
        let res = await Inbox.openMessages(messageIds: [])
        expect(res).to(beTrue())
    }

    func test_openMessagesShouldReturnFalseIfResponseIsError() async throws {
        let badResponse = StubBuilder(test: self, resource: .failure_server_error).build()
        stub(http(.post, uri: "/v2native/inbox/openMessages"), badResponse)
        let res = await Inbox.openMessages(messageIds: [])
        expect(res).to(beFalse())
    }
}
