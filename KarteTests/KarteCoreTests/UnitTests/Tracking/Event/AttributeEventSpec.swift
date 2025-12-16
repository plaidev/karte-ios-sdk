//
//  Copyright 2021 PLAID, Inc.
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

class AttributeEventSpec: QuickSpec {

    override class func spec() {
        describe("a attribute event") {
            var event: Event!
            
            beforeEach {
                event = Event(.attribute(values: [
                    "key": "value"
                ]))
            }
            
            describe("its eventName") {
                it("is attribute") {
                    expect(event.eventName).to(equal(.attribute))
                }
            }
            
            describe("its values") {
                it("is not nil") {
                    expect(event.values).toNot(beNil())
                }
                it("count is 1") {
                    expect(event.values.count).to(equal(1))
                }
                
                it("values.key is `value`") {
                    expect(event.values.string(forKey: "key")).to(equal("value"))
                }
            }
        }
    }
}
