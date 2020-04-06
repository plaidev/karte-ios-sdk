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

class InspectorSpec: QuickSpec {
    
    override func spec() {
        describe("a inspector") {
            describe("its inspectText") {
                context("when passing nil") {
                    it("returns nil") {
                        let actual = Inspector.inspectText(with: nil)
                        expect(actual).to(beNil())
                    }
                }
                
                context("when passing UIButton that has not text") {
                    it("returns nil") {
                        let actual = Inspector.inspectText(with: UIButton(type: .infoDark))
                        expect(actual).to(beNil())
                    }
                }
                
                context("when passing UIButton that has text") {
                    it("returns text") {
                        let button = UIButton(type: .system)
                        button.titleLabel?.text = "text"
                        let actual = Inspector.inspectText(with: button)
                        expect(actual).to(equal("text"))
                    }
                }
                
                context("when passing superView of UILabel") {
                    it("returns text") {
                        let view = UIView()
                        let label = UILabel()
                        label.text = "text"
                        view.addSubview(label)
                        let actual = Inspector.inspectText(with: view)
                        expect(actual).to(equal("text"))
                    }
                }
                
                context("when passing UITabBarItem") {
                    it("returns text") {
                        let tabBar = UITabBarItem()
                        tabBar.title = "text"
                        let actual = Inspector.inspectText(with: tabBar)
                        expect(actual).to(equal("text"))
                    }
                }
                
            }
            
            describe("its takeSnapshot") {
                context("when passing nil") {
                    it("returns nil") {
                        let actual = Inspector.takeSnapshot(with: nil)
                        expect(actual).to(beNil())
                    }
                }
                                
                context("when passing UIButton") {
                    it("returns not nil") {
                        let actual = Inspector.takeSnapshot(with: UIButton(type: .infoDark))
                        expect(actual).toNot(beNil())
                    }
                }
            }
        }
    }
    
}
