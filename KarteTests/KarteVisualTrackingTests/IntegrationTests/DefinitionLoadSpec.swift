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

class DefinitionLoadSpec: QuickSpec {
    
    override class func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .vt2).build()
        }
        
        describe("a definition load") {
            var request: URLRequest!

            beforeEach { (metadata: ExampleMetadata) in
                let eventName = EventName("foo")
                let module = StubActionModule(self, metadata: metadata, builder: builder)
                
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                Tracker.track(event: Event(eventName: eventName))
                
                request = module.wait().request(eventName)
            }
            
            describe("its request") {
                it("has `X-KARTE-Auto-Track-OS` header") {
                    expect(request.allHTTPHeaderFields?.keys.contains("X-KARTE-Auto-Track-OS")).to(beTrue())
                }
                
                it("`X-KARTE-Auto-Track-OS` header value is `iOS`") {
                    expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-OS"]).to(equal("iOS"))
                }
                
                it("has `X-KARTE-Auto-Track-If-Modified-Since` header") {
                    expect(request.allHTTPHeaderFields?.keys.contains("X-KARTE-Auto-Track-If-Modified-Since")).to(beTrue())
                }
                
                it("`has X-KARTE-Auto-Track-If-Modified-Since` header that value is `0`") {
                    expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-If-Modified-Since"]).to(equal("0"))
                }
            }
            
            describe("its definitions") {
                var definitions: AutoTrackDefinition?
                beforeEach {
                    definitions = VisualTrackingManager.shared.tracker?.definitions
                }
                
                it("is not nil") {
                    expect(definitions).toNot(beNil())
                }
                
                it("only has valid trigger") {
                    expect(definitions?.definitions?.first?.triggers.count).to(equal(2))
                }
                
                it("only has valid conditions") {
                    if case let .and(c) = definitions?.definitions?.first?.triggers.first?.condition {
                        expect(c.count).to(equal(2))
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
