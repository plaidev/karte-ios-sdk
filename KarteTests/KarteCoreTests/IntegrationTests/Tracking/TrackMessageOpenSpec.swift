//
//  Copyright 2023 PLAID, Inc.
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
@testable import KarteUtilities
@testable import KarteCore
@testable import KarteInAppMessaging

final class TrackMessageOpenSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!

        func runTest(metadata: ExampleMetadata?, responseTimestamp: Date, libraryName: String? = nil) -> StubActionModule {
            let module = StubActionModule(self, metadata: metadata, builder: builder)
            
            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
            
            Tracker.track(event: Event(.message(type: .open, campaignId: "cid", shortenId: "sid", values: [
                "message": [
                    "response_timestamp": iso8601DateTimeFormatter.string(from: responseTimestamp)
                ]
            ]), libraryName: libraryName))
            
            return module
        }

        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("message_open expired check") {
            var event: Event?
            
            beforeEach {
                KarteApp.shared.register(module: .track(InAppMessaging()))
            }
            
            afterEach {
                KarteApp.shared.unregister(module: .track(InAppMessaging()))
            }

            context("libraryName is in_app_messaging") {
                context("expired") {
                    beforeEachWithMetadata { metadata in
                        event = runTest(metadata: metadata, responseTimestamp: Date(timeIntervalSince1970: 0), libraryName: InAppMessaging.name)
                            .wait()
                            .event(.messageOpen)
                    }
                    
                    it("event is nil") {
                        expect(event).to(beNil())
                    }
                }
                
                context("not expired") {
                    beforeEachWithMetadata { metadata in
                        event = runTest(metadata: metadata, responseTimestamp: Date(), libraryName: InAppMessaging.name)
                            .wait()
                            .event(.messageOpen)
                    }
                    
                    it("event is not nil") {
                        expect(event).toNot(beNil())
                    }
                }
            }
            
            context("libraryName is not in_app_messaging") {
                context("not expired 1") {
                    beforeEachWithMetadata { metadata in
                        event = runTest(metadata: metadata, responseTimestamp: Date(timeIntervalSince1970: 0))
                            .wait()
                            .event(.messageOpen)
                    }
                    
                    it("event is nil") {
                        expect(event).toNot(beNil())
                    }
                }
                
                context("not expired 2") {
                    beforeEachWithMetadata { metadata in
                        event = runTest(metadata: metadata, responseTimestamp: Date())
                            .wait()
                            .event(.messageOpen)
                    }
                    
                    it("event is not nil") {
                        expect(event).toNot(beNil())
                    }
                }
            }
        }
    }
}
