//
//  Copyright 2020 PLAID, Inc.
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
@testable import KarteVisualTracking

class AccountSpec: XCTestCase {

    func testAccountIsNilWhenHostIsNotKrtp() throws {
        let url = try XCTUnwrap(URL(string: "app://karte.io/dummy_account_id"))
        let account = Account(url: url)
        XCTAssertNil(account, "account is nil when host is not `_krtp`")
    }

    func testAccountIsNilWhenLastPathComponentIsEmpty() throws {
        let url = try XCTUnwrap(URL(string: "app://karte.io/"))
        let account = Account(url: url)
        XCTAssertNil(account, "account is nil when last path component is empty")
    }

    func testValidURL() throws {
        let url = try XCTUnwrap(URL(string: "app://_krtp/dummy_account_id"))
        guard let account = Account(url: url) else {
            XCTFail("account should not be nil for valid url")
            return
        }
        XCTAssertEqual(account.id, "dummy_account_id", "id is `dummy_account_id`")
    }
}
