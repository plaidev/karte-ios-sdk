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
@testable import KarteVisualTracking

class ActionFactorySpec: QuickSpec {
    
    override func spec() {
        describe("a action") {
            describe("its init") {
                let action = ActionFactory.createForUIKit(actionName: "test_touch",
                                                          view: UIView.init(frame: .init(x: 0, y: 0, width: 100, height: 100)),
                                                          viewController: nil,
                                                          targetText: "test_text",
                                                          actionId: "test_action_id")
                it("action  is `touch`") {
                    expect(action?.action).to(equal("test_touch"))
                }
                
                it("screenName  is not nil") {
                    expect(action?.screenName).toNot(beNil())
                }
                
                it("screenHostName  is nil") {
                    expect(action?.screenHostName).to(beNil())
                }
                
                it("targetText  is `test_text`") {
                    expect(action?.targetText).to(equal("test_text"))
                }
                                
                it("actionId  is `test_action_id`") {
                    expect(action?.actionId).to(equal("test_action_id"))
                }
                
                it("image is not nil") {
                    expect(action?.image()).toNot(beNil())
                }
            }
        }
    }
}
