//
//  Copyright 2024 PLAID, Inc.
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

final class InAppFrameSpec: XCTestCase {
    func test_fetchMessagesShouldBeParsedWithoutError() async throws {
        let successResponse = StubBuilder(test: self, resource: .inappframe_carousel_without_margin).build()
        stub(http(.post, uri: "/v2native/inbox/fetchMessages"), successResponse)
//        guard let res = await Inbox.fetchMessages() else {
//            XCTFail("Should never be executed")
//            return
//        }

//        expect(res.count).to(equal(2))
//        expect(res[0].title).to(equal("title1"))
//        expect(res[0].body).to(equal("body1"))
//        expect(res[0].campaignId).to(equal("dummy_campaignId_1"))
//        expect(res[0].messageId).to(equal("dummy_messageId_1"))
//        expect(res[0].timestamp).notTo(beNil())
//        expect(res[0].attachmentUrl).to(beEmpty())
//        expect(res[0].linkUrl).to(beEmpty())
//        expect(res[0].isRead).to(beTrue())
//
//        expect(res[1].title).to(equal("title2"))
//        expect(res[1].body).to(equal("body2"))
//        expect(res[1].campaignId).to(equal("dummy_campaignId_2"))
//        expect(res[1].messageId).to(equal("dummy_messageId_2"))
//        expect(res[1].timestamp).notTo(beNil())
//        expect(res[1].attachmentUrl).to(beEmpty())
//        expect(res[1].linkUrl).to(beEmpty())
//        expect(res[1].isRead).to(beFalse())
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
