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
@testable import KarteVisualTracking

class ActionSpec: QuickSpec {
    
    override class func spec() {
        describe("a action") {
            describe("its init") {
                describe("property") {
                    context("when a simple view structure") {
                        var viewController: UIViewController!
                        var button: UIButton!
                        var action: UIKitAction!
                        
                        beforeEach {
                            viewController = UIViewController()
                            button = UIButton(type: .system)
                            action = UIKitAction(
                                "dummy_action",
                                view: button,
                                viewController: viewController,
                                targetText: "dummy_target_text",
                                actionId: UIKitAction.actionId(view: button)
                            )
                        }
                        
                        it("action is `dummy_action`") {
                            expect(action.action).to(equal("dummy_action"))
                        }
                        
                        it("view is UIButton") {
                            expect(action.view).to(equal(button))
                        }
                        
                        it("viewController is UIViewController") {
                            expect(action.viewController).to(equal(viewController))
                        }
                        
                        it("targetText is `dummy_target_text`") {
                            expect(action.targetText).to(equal("dummy_target_text"))
                        }
                        
                        it("actionId is `UIButton`") {
                            expect(action.actionId).to(equal("UIButton"))
                        }
                    }
                    context("when a complex view structure") {
                        var viewController: UIViewController!
                        var firstView: UIView!
                        var secondView: UIView!
                        var button0: UIButton!
                        var button1: UIButton!
                        
                        beforeEach {
                            viewController = UIViewController()
                            firstView = UIView()
                            secondView = UIView()
                            button0 = UIButton(type: .infoDark)
                            button1 = UIButton(type: .infoLight)
                            firstView.addSubview(secondView)
                            secondView.addSubview(button0)
                            secondView.addSubview(button1)
                        }
                        
                        it("button index of actionId is 0") {
                            let action = UIKitAction(
                                "dummy_action",
                                view: button0,
                                viewController: viewController,
                                targetText: "dummy_target_text",
                                actionId: UIKitAction.actionId(view: button0)
                            )
                            expect(action!.actionId!).to(equal("UIButton0UIView0UIView"))
                        }
                        it("button index of actionId is 1") {
                            let action = UIKitAction(
                                "dummy_action",
                                view: button1,
                                viewController: viewController,
                                targetText: "dummy_target_text",
                                actionId: UIKitAction.actionId(view: button1)
                            )
                            expect(action!.actionId!).to(equal("UIButton1UIView0UIView"))
                        }
                        
                        it("actionId is overridden by argument") {
                            let action = UIKitAction(
                                "dummy_action",
                                view: button1,
                                viewController: viewController,
                                targetText: "dummy_target_text",
                                actionId: "dummy_action_id"
                            )
                            expect(action!.actionId!).to(equal("dummy_action_id"))
                        }

                        it("actionId is nil") {
                            let action = UIKitAction(
                                "dummy_action",
                                view: nil,
                                viewController: viewController,
                                targetText: "dummy_target_text"
                            )
                            expect(action!.actionId).to(beNil())
                        }
                    }
                    
                    context("when pass an ignore action name") {
                        it("returns nil") {
                            let action = UIKitAction(
                                "handlePan:",
                                view: UIView(),
                                viewController: UIViewController(),
                                targetText: "dummy_target_text"
                            )
                            expect(action).to(beNil())
                        }
                    }
                    
                    context("when pass nil for view / viewController") {
                        it("screenName / hostName return nil") {
                            let action = UIKitAction(
                                "test_action",
                                view: nil,
                                viewController: nil,
                                targetText: "dummy_target_text"
                            )
                            expect(action?.screenName).to(beNil())
                            expect(action?.screenHostName).to(beNil())
                        }
                    }
                    
                    context("when pass nil for view / viewController / targetText") {
                        it("returns nil") {
                            let action = UIKitAction(
                                "test_action",
                                view: nil,
                                viewController: nil,
                                targetText: nil
                            )
                            expect(action).to(beNil())
                        }
                    }
                }
            }
            describe("its viewPathIndices") {
                context("when passing nil") {
                    it("returns empty array") {
                        let actual = UIKitAction.viewPathIndices(actionId: nil)
                        expect(actual).to(equal([]))
                    }
                }
                context("when passing empty string") {
                    it("returns empty array") {
                        let actual = UIKitAction.viewPathIndices(actionId: "")
                        expect(actual).to(equal([]))
                    }
                }
                context("when passing UIView") {
                    it("returns empty array") {
                        let actual = UIKitAction.viewPathIndices(actionId: "UIView")
                        expect(actual).to(equal([]))
                    }
                }
                context("when passing UIView0") {
                    it("returns array with 0") {
                        let actual = UIKitAction.viewPathIndices(actionId: "UIView0")
                        expect(actual).to(equal([0]))
                    }
                }
                context("when passing complexView") {
                    it("returns array with 0,0,0,0,0,0,0,11") {
                        let actual = UIKitAction.viewPathIndices(actionId:  "UIView11UITableView0UIView0UIViewControllerWrapperView0UINavigationTransitionView0UILayoutContainerView0UIDropShadowView0UITransitionView0SimpleUIWindow")
                        expect(actual).toNot(beNil())
                        expect(actual).to(equal([0,0,0,0,0,0,0,11]))
                    }
                }
                context("when passing UIView999UIView2000UIView3000") {
                    it("returns array with 3000,2000,999") {
                        let actual = UIKitAction.viewPathIndices(actionId: "UIView999UIView2000UIView3000")
                        expect(actual).to(equal([3000,2000,999]))
                    }
                }
            }
        }
    }
}
