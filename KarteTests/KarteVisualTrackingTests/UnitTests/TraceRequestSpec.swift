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

class TraceRequestSpec: QuickSpec {

    override func spec() {
        describe("a trace request") {
            describe("init") {
                let url = URL(string: "app://_krtp/dummy_account_id")
                let account = Account(url: url!)
                
                let service = MixInCoreServiceMock(configuration: Configuration.defaultConfiguration)
                KarteApp.shared.setup(service: service)

                context("when action has actionId") {
                    let view = UIView()
                    let button = UIButton(type: .infoDark)
                    view.addSubview(button)
                    let action = Action("touch",
                                        view: button,
                                        viewController: UIViewController(),
                                        targetText: "dummy_target_text")
                    let request = TraceRequest(app: KarteApp.shared,
                                               account: account!,
                                               action: action!,
                                               image: nil)
                    it("request has action that has actionId") {
                        expect(request?.action).notTo(beNil())
                        expect(request?.action.actionId).to(equal("UIButton0UIView"))
                    }
                }
                context("when action does not has actionId") {
                    let action = Action("touch",
                                        view: nil,
                                        viewController: UIViewController(),
                                        targetText: "dummy_target_text")
                    let request = TraceRequest(app: KarteApp.shared,
                                               account: account!,
                                               action: action!,
                                               image: nil)
                    it("request has action that does not has actionId") {
                        expect(request?.action).notTo(beNil())
                        expect(request?.action.actionId).to(beNil())
                    }
                }
            }
        }
    }
}
