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

class RenewVisitorIdEventSpec: QuickSpec {
    
    override class func spec() {
        describe("a renew visitor id event") {
            var event: Event!
            
            context("when old visitor id is not nil") {
                beforeEach {
                    event = Event(.renewVisitorId(old: "old_visitor_id", new: nil))
                }
                
                describe("its eventName") {
                    it("is nativeAppRenewVisitorId") {
                        expect(event.eventName).to(equal(.nativeAppRenewVisitorId))
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
                    
                    it("values.old_visitor_id is `old_visitor_id`") {
                        expect(event.values.string(forKey: "old_visitor_id")).to(equal("old_visitor_id"))
                    }
                }
            }
            
            context("when new visitor id is not nil") {
                beforeEach {
                    event = Event(.renewVisitorId(old: nil, new: "new_visitor_id"))
                }
                
                describe("its build values") {
                    it("count is 1") {
                        expect(event.values.count).to(equal(1))
                    }
                    
                    it("values.new_visitor_id is `new_visitor_id`") {
                        expect(event.values.string(forKey: "new_visitor_id")).to(equal("new_visitor_id"))
                    }
                }
            }
        }
    }
}
