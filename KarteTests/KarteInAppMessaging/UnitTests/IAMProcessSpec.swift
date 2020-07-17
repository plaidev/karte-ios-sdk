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

import UIKit
import Quick
import Nimble
@testable import KarteCore
@testable import KarteInAppMessaging

class IAMProcessSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var iamConfiguration: IAMProcessConfiguration!
        var view: UIView!
        var iamProcess: IAMProcess!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
        }
        
        describe("its init") {
            beforeEach {
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                iamConfiguration = IAMProcessConfiguration(app: KarteApp.shared)
                view = UIView.init()
                iamProcess = IAMProcess(view: view, configuration: iamConfiguration)
            }
            it("is not nil") {
                expect(iamProcess).toNot(beNil())
                expect(IAMProcess.processPool).toNot(beNil())
            }
            it("sceneId is not nil") {
                expect(iamProcess.sceneId).toNot(beNil())
            }
            it("isActivated is true") {
                expect(iamProcess.isActivated).to(beTrue())
            }
            it("isPresenting is false") {
                expect(iamProcess.isPresenting).to(beFalse())
            }
            it("isSuppressed is false") {
                expect(iamProcess.isSuppressed).to(beFalse())
            }
        }
        
        describe("its terminate") {
            beforeEach {
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                iamConfiguration = IAMProcessConfiguration(app: KarteApp.shared)
                view = UIView.init()
                iamProcess = IAMProcess(view: view, configuration: iamConfiguration)
                iamProcess.terminate()
            }
            
            it("is not nil") {
                expect(iamProcess).toNot(beNil())
            }
            it("sceneId is not nil") {
                expect(iamProcess.sceneId).toNot(beNil())
            }
            it("isActivated is false") {
                expect(iamProcess.isActivated).to(beFalse())
            }
            it("isPresenting is false") {
                expect(iamProcess.isPresenting).to(beFalse())
            }
            it("isSuppressed is false") {
                expect(iamProcess.isSuppressed).to(beFalse())
            }
        }
        
        describe("its activate") {
            beforeEach {
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                iamConfiguration = IAMProcessConfiguration(app: KarteApp.shared)
                view = UIView.init()
                iamProcess = IAMProcess(view: view, configuration: iamConfiguration)
            }
            context("only activated") {
                it("isActivated is true") {
                    iamProcess.activate()
                    expect(iamProcess.isActivated).to(beTrue())
                }
            }

            context("after terminate") {
                it("isActivated is true") {
                    iamProcess.terminate()
                    expect(iamProcess.isActivated).to(beFalse())
                    iamProcess.activate()
                    expect(iamProcess.isActivated).to(beTrue())
                }
            }
        }
    }
}
