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

class ViewEventSpec: QuickSpec {
    
    override class func spec() {
        describe("a view event") {
            context("when view_id is not nil") {
                var event: Event!
                
                beforeEach {
                    event = Event(.view(viewName: "view_name", title: "title", values: [
                        "key": "value",
                        "view_id": "view_id"
                    ]))
                }
                
                describe("its values") {
                    it("count is 4") {
                        expect(event.values.count).to(equal(4))
                    }

                    it("values.key is `value`") {
                        expect(event.values.string(forKey: "key")).to(equal("value"))
                    }
                    
                    it("values.view_name is `view_name") {
                        expect(event.values.string(forKey: "view_name")).to(equal("view_name"))
                    }
                    
                    it("values.view_id is `view_id`") {
                        expect(event.values.string(forKey: "view_id")).to(equal("view_id"))
                    }
                    
                    it("values.title is `title`") {
                        expect(event.values.string(forKey: "title")).to(equal("title"))
                    }
                }
            }
        }
    }
}
