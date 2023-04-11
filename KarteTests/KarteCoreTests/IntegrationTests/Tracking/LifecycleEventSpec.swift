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
import KarteUtilities
@testable import KarteCore

class LifecycleEventSpec: QuickSpec {
    
    override func spec() {
        var builder: Builder!
        
        beforeSuite {
            builder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("a karte app") {
            describe("its setup") {
                context("when use default config") {
                    context("when after launch") {
                        var event: Event!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder)

                            KarteApp.setup(appKey: APP_KEY)

                            event = module.wait().event(.nativeAppOpen)
                        }

                        it("occurred native_app_open event") {
                            expect(event).toNot(beNil())
                        }
                    }
                    context("when after installation") {
                        var event: Event!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder)

                            KarteApp.setup(appKey: APP_KEY)

                            event = module.wait().event(.nativeAppInstall)
                        }

                        it("occurred native_app_install event") {
                            expect(event).toNot(beNil())
                        }
                    }
                    context("when after update") {
                        var event: Event!
                        var versionRetriever: VersionRetrieverMock!
                        
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder)
                            
                            versionRetriever = VersionRetrieverMock()
                            
                            Resolver.root = Resolver.submock
                            Resolver.root.register(name: "version_service.current_version_retriever") {
                                versionRetriever as VersionRetriever
                            }
                            
                            _ = VersionService()
                            versionRetriever.ver = "1.0.1"
                            
                            KarteApp.setup(appKey: APP_KEY)
                            
                            event = module.wait().event(.nativeAppUpdate)
                        }
                        
                        afterEach {
                            Resolver.root = Resolver.mock
                        }
                        
                        it("occurred native_app_update event") {
                            expect(event).toNot(beNil())
                        }
                        
                        it("values.prev_version_name is `1.0.0`") {
                            expect(event.values.string(forKey: field(.previousVersionName))).to(equal("1.0.0"))
                        }
                    }
                    context("when not after installation or update") {
                        var events: [Event] = []
                        var versionRetriever: VersionRetrieverMock!

                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder)

                            versionRetriever = VersionRetrieverMock()

                            Resolver.root = Resolver.submock
                            Resolver.root.register(name: "version_service.current_version_retriever") {
                                versionRetriever as VersionRetriever
                            }

                            _ = VersionService()
                            versionRetriever.ver = "1.0.0"

                            KarteApp.setup(appKey: APP_KEY)

                            events.append(contentsOf: module.wait().events([.nativeAppInstall, .nativeAppUpdate]))
                        }

                        afterEach {
                            Resolver.root = Resolver.mock
                        }

                        it("not occurred native_app_install and native_app_update event") {
                            expect(events.count).to(equal(0))
                        }
                    }
                }
            }
        }
    }
}
