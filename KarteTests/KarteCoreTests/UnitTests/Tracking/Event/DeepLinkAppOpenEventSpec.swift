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
@testable import KarteCore

class DeepLinkAppOpenEventSpec: QuickSpec {
    
    override class func spec() {
        describe("a `deep_link_app_open` event") {
            var event: Event!
            
            beforeEach {
                event = Event(.deepLinkAppOpen(url: "deep-link"))
            }
            
            describe("its eventName") {
                it("is deepLinkAppOpen") {
                    expect(event.eventName).to(equal(.deepLinkAppOpen))
                }
            }
            
            describe("its values") {
                it("is not nil") {
                    expect(event.values).toNot(beNil())
                }
            }
            
            describe("its build values") {
                it("count is 1") {
                    expect(event.values.count).to(equal(1))
                }
                
                it("values.url is `deep-link`") {
                    expect(event.values.string(forKey: "url")).to(equal("deep-link"))
                }
            }
        }
    }
}
