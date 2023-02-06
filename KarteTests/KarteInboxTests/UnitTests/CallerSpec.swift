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
import KarteUtilities
@testable import KarteCore
@testable import KarteInbox

final class CallerSpec: QuickSpec {
    @available(iOS 15.0, *)
    func testNativeAsyncCaller_shouldReturnNil_withInvalidUserId() async {
        let caller = NativeAsyncCaller()
        let req = FetchMessagesRequest(userId: "Dummy userId")
        let res = await caller(callee: req)
        expect(res).to(beNil())
    }

    @available(iOS 15.0, *)
    func testNativeAsyncCaller_shouldReturnNil_withInvalidURL() async {
        let caller = NativeAsyncCaller()
        let res = await caller(callee: DummyRequest())
        expect(res).to(beNil())
    }

    func testFallbackAsyncCaller_shouldReturnNil_withInvalidUserId() async {
        let caller = FallbackAsyncCaller()
        let req = FetchMessagesRequest(userId: "Dummy userId")
        let res = await caller(callee: req)
        expect(res).to(beNil())
    }

     func testFallbackAsyncCaller_shouldReturnNil_withInvalidURL() async {
        let caller = FallbackAsyncCaller()
        let res = await caller(callee: DummyRequest())
        expect(res).to(beNil())
    }
}

private struct DummyRequest: BaseAPIRequest {
    typealias Response = String

    var method: HTTPMethod {
        .get
    }

    var path: String {
        "dummy-url"
    }
}
