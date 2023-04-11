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

class TrackCallbackSpec: QuickSpec {

    override func spec() {
        var configuration: KarteCore.Configuration!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
        }
        
        describe("a tracker") {
            describe("its track callback") {
                context("request success") {
                    var result: Bool!
                    beforeEachWithMetadata { (metadata) in
                        let builder = StubBuilder(spec: self, resource: .empty).build()
                        let module = StubActionModule(self, metadata: metadata, builder: builder)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                        let event = Event(eventName: EventName("test"))
                        let task = Tracker.track(event: event)
                        task.completion = { (res) in
                            result = res
                        }
                        
                        module.wait()
                    }
                    
                    it("result is true") {
                        expect(result).to(beTrue())
                    }
                }
                
                context("request failure") {
                    var result: Bool!
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(
                            self,
                            metadata: metadata,
                            stub: self.stub(uri("/v0/native/track"), http(500))
                        )
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                        let event = Event(eventName: .fetchVariables)
                        let task = Tracker.track(event: event)
                        task.completion = { (res) in
                            result = res
                            module.finish()
                        }
                        
                        module.wait()
                    }
                    
                    it("result is false") {
                        expect(result).to(beFalse())
                    }
                }
            }
        }
    }
}
