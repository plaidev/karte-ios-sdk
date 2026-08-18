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

final class InboxSpec: XCTestCase {
    func testFetchMessagesShouldBeParsedWithoutError() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success).build()
        stub(http(.post, path: "/v2native/inbox/fetchMessages"), successResponse)
        guard let res = await Inbox.fetchMessages() else {
            XCTFail("Should never be executed")
            return
        }

        XCTAssertEqual(res.count, 2, "message count")
        XCTAssertEqual(res[0].title, "title1", "res[0].title")
        XCTAssertEqual(res[0].body, "body1", "res[0].body")
        XCTAssertEqual(res[0].campaignId, "dummy_campaignId_1", "res[0].campaignId")
        XCTAssertEqual(res[0].messageId, "dummy_messageId_1", "res[0].messageId")
        XCTAssertTrue(res[0].attachmentUrl.isEmpty, "res[0].attachmentUrl")
        XCTAssertTrue(res[0].linkUrl.isEmpty, "res[0].linkUrl")
        XCTAssertTrue(res[0].isRead, "res[0].isRead")

        XCTAssertEqual(res[1].title, "title2", "res[1].title")
        XCTAssertEqual(res[1].body, "body2", "res[1].body")
        XCTAssertEqual(res[1].campaignId, "dummy_campaignId_2", "res[1].campaignId")
        XCTAssertEqual(res[1].messageId, "dummy_messageId_2", "res[1].messageId")
        XCTAssertTrue(res[1].attachmentUrl.isEmpty, "res[1].attachmentUrl")
        XCTAssertTrue(res[1].linkUrl.isEmpty, "res[1].linkUrl")
        XCTAssertFalse(res[1].isRead, "res[1].isRead")
    }

    func testCustomPayloadShouldBeParsedProperly() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success).build()
        stub(http(.post, path: "/v2native/inbox/fetchMessages"), successResponse)
        guard let res = await Inbox.fetchMessages(), res.count == 2 else {
            XCTFail("Should never be executed")
            return
        }

        let msg1 = res[0]
        XCTAssertEqual(msg1.customPayload["keyStr"] as? String, "Dummy", "keyStr")
        XCTAssertEqual(msg1.customPayload["keyInt"] as? Int, 10, "keyInt")
        XCTAssertEqual(msg1.customPayload["keyDouble"] as? Double, 1.11, "keyDouble")
        XCTAssertEqual(msg1.customPayload["keyArray"] as? [Int], [1, 2, 3], "keyArray")
        XCTAssertNil(msg1.customPayload["keyNull"] ?? nil, "keyNull")

        guard let nestedMap = res[0].customPayload["keyMap"] as? [String: Any] else {
            XCTFail("Should never be executed: nestedMap in customPayload must be parsed: \(msg1.customPayload)")
            return
        }
        XCTAssertEqual(nestedMap["prop1"] as? String, "hoge", "keyMap.prop1")
        XCTAssertEqual(nestedMap["prop2"] as? Int, 0, "keyMap.prop2")

        let msg2 = res[1]
        XCTAssertEqual(msg2.customPayload.count, 0, "msg2.customPayload count")
    }

    func testFetchMessagesShouldReturnNilWith400Errors() async throws {
        let badResponse400 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 400)
        let badResponse401 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 401)
        let badResponse403 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 403)
        let badResponse404 = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 404)

        stub(http(.post, path: "/v2native/inbox/fetchMessages"), badResponse400)
        let res1 = await Inbox.fetchMessages()
        XCTAssertNil(res1, "400 returns nil")

        stub(http(.post, path: "/v2native/inbox/fetchMessages"), badResponse401)
        let res2 = await Inbox.fetchMessages()
        XCTAssertNil(res2, "401 returns nil")

        stub(http(.post, path: "/v2native/inbox/fetchMessages"), badResponse403)
        let res3 = await Inbox.fetchMessages()
        XCTAssertNil(res3, "403 returns nil")

        stub(http(.post, path: "/v2native/inbox/fetchMessages"), badResponse404)
        let res4 = await Inbox.fetchMessages()
        XCTAssertNil(res4, "404 returns nil")
    }

    func testFetchMessagesShouldReturnNilWith500Error() async throws {
        let badResponse500 = StubBuilder(test: self, resource: .failure_server_error).build()
        stub(http(.post, path: "/v2native/inbox/fetchMessages"), badResponse500)
        let res = await Inbox.fetchMessages()
        XCTAssertNil(res, "500 returns nil")
    }

    func testFetchMessagesShouldReturnNilWithInvalidData() async {
        let badResponse = Data("""
        {
            "messages": [
                { "wrong_key": "invalid value" }
            ]
        }
        """.utf8)
        stub(http(.post, path: "/v2native/inbox/fetchMessages"), jsonData(badResponse))
        let res = await Inbox.fetchMessages()
        XCTAssertNil(res, "invalid data returns nil")
    }

    func testOpenMessagesShouldReturnTrueIfResponseIsSuccess() async throws {
        let successResponse = StubBuilder(test: self, resource: .inbox_success_empty).build()
        stub(http(.post, path: "/v2native/inbox/openMessages"), successResponse)
        let res = await Inbox.openMessages(messageIds: [])
        XCTAssertTrue(res, "openMessages returns true on success")
    }

    func testOpenMessagesShouldReturnFalseIfResponseIsError() async throws {
        let badResponse = StubBuilder(test: self, resource: .failure_server_error).build()
        stub(http(.post, path: "/v2native/inbox/openMessages"), badResponse)
        let res = await Inbox.openMessages(messageIds: [])
        XCTAssertFalse(res, "openMessages returns false on error")
    }
}
