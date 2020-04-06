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

import Quick
import Nimble
@testable import KarteVisualTracking

class AccountSpec: QuickSpec {
    
    override func spec() {
        describe("a account") {
            context("when host is not `_krtp`") {
                it("account is nil") {
                    let account = Account(url: URL(string: "app://karte.io/dummy_account_id")!)
                    expect(account).to(beNil())
                }
            }
            
            context("when last path component is empty") {
                it("account is nil") {
                    let account = Account(url: URL(string: "app://karte.io/")!)
                    expect(account).to(beNil())
                }
            }
            
            context("when valid url") {
                var account: Account?
                
                beforeEach {
                    account = Account(url: URL(string: "app://_krtp/dummy_account_id")!)
                }
                
                it("account is not nil") {
                    expect(account).toNot(beNil())
                }
                
                it("id is `dummy_account_id`") {
                    expect(account?.id).to(equal("dummy_account_id"))
                }
            }
        }
    }
}
