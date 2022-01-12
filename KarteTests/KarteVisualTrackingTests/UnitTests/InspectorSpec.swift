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
            describe("its inspectView") {
                var window: UIWindow!
                var view1: UIView!
                var view2: UIView!
                var view3: UIView!
                var view4: UIView!

                beforeEach {
                    window = UIWindow()
                    view1 = UIView()
                    view2 = UIView()
                    view3 = UIView()
                    view4 = UIView()
                    view1.addSubview(view2)
                    view2.addSubview(view3)
                    view2.addSubview(view4)
                    window.addSubview(view1)
                }

                context("when passing inWindow nil") {
                    it("returns nil") {
                        let actual = Inspector.inspectView(with: [0], inWindow: nil)
                        expect(actual).to(beNil())
                    }
                }
                context("when passing empty array") {
                    it("returns nil") {
                        let actual = Inspector.inspectView(with: [], inWindow: UIWindow())
                        expect(actual).to(beNil())
                    }
                }
                context("when passing out-of-bounds indices") {
                    it("returns nil") {
                        let viewPathIndices = UIKitAction.viewPathIndices(actionId: "Olympic0View11UIView0")
                        let actual = Inspector.inspectView(with: viewPathIndices, inWindow: window)
                        expect(actual).to(beNil())
                    }
                }
                context("when passing UIView1UIView0UIView0UIWindow") {
                    it("returns not nil") {
                        let actionId = UIKitAction.actionId(view: view4)
                        let viewPathIndices = UIKitAction.viewPathIndices(actionId: actionId)
                        let actual = Inspector.inspectView(with: viewPathIndices, inWindow: window)
                        expect(actual).toNot(beNil())
                        expect(actionId).to(equal("UIView1UIView0UIView0UIWindow"))
                    }
                }
            }
            
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
