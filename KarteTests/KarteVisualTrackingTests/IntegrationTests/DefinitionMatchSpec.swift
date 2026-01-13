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
import Mockingjay
@testable import KarteCore
@testable import KarteVisualTracking

class DefinitionMatchSpec: QuickSpec {
    
    override class func spec() {
        var configuration: KarteCore.Configuration!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
        }
        
        describe("match definition and track") {
            var event: Event!
            
            beforeEach { (metadata: ExampleMetadata) in
                func step1() {
                    let builder1 = StubBuilder(spec: self, resource: .vt1).build()
                    let module1 = StubActionModule(self, metadata: metadata, builder: builder1)
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    Tracker.track(event: Event(.view(viewName: "dummy", title: "dummy", values: [:])))
                    
                    module1.wait()
                }
                
                func step2() {
                    let builder2 = StubBuilder(spec: self, resource: .empty).build()
                    let module2 = StubActionModule(self, metadata: metadata, builder: builder2)
                    
                    let action = UIKitAction("dummy", view: UIButton(), viewController: nil, targetText: "購入")
                    VisualTrackingManager.shared.dispatch(action: action)
                    
                    event = module2.wait().event(.view)
                }
                
                step1()
                step2()
            }
            
            it("eventName is `view`") {
                expect(event.eventName).to(equal(.view))
            }
            
            it("values._auto_track") {
                expect(event.values.integer(forKeyPath: "_system.auto_track")).to(equal(1))
            }
            
            it("values.foo is `bar`") {
                expect(event.values.string(forKey: "foo")).to(equal("bar"))
            }
        }
    }
}
