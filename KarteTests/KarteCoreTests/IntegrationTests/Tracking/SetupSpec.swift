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

class SetupSpec: QuickSpec {
    
    override func spec() {
        var builder: Builder!
        
        beforeSuite {
            builder = StubBuilder(spec: self, resource: .empty).build()
        }

        describe("a karte app") {
            describe("its setup") {
                context("when use default config") {
                    var request: URLRequest!
                    var body: TrackBodyParameters!
                    var events: [Event] = []
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: builder, eventNames: [.nativeAppOpen, .nativeAppInstall]) { (r, b, e) in
                            request = r
                            body = b
                            events.append(e)
                        }

                        KarteApp.setup(appKey: APP_KEY)
                        
                        module.wait()
                    }
                    it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
                        expect(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(APP_KEY))
                    }
                    
                    it("Request Header contains `Content-Encoding: gzip`") {
                        expect(request.allHTTPHeaderFields!["Content-Encoding"]!).to(equal("gzip"))
                    }
                    
                    it("Request URL is `https://api.karte.io/v0/native/track`") {
                        expect(request.url!.absoluteString).to(equal("https://api.karte.io/v0/native/track"))
                    }
                    
                    it("occurred native_app_open event") {
                        let contain = events.contains(where: { $0.eventName == .nativeAppOpen })
                        expect(contain).to(beTrue())
                    }
                    
                    it("occurred native_app_install event") {
                        let contain = events.contains(where: { $0.eventName == .nativeAppInstall })
                        expect(contain).to(beTrue())
                    }
                    
                    it("idfa is nil") {
                        expect(body.appInfo.systemInfo.idfa).to(beNil())
                    }
                }
                
                context("when use custom config") {
                    context("when customized base url") {
                        var request: URLRequest!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }
                            let configuration = Configuration { (configuration) in
                                configuration.baseURL = URL(string: "https://t.karte.io")!
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            
                            module.wait()
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                    }
                    
                    context("when enabled dry run") {
                        beforeEach {
                            let configuration = Configuration { (configuration) in
                                configuration.isDryRun = true
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        }
                        
                        it("tracker is nil") {
                            expect(KarteApp.shared.trackingService).to(beNil())
                        }
                    }
                    
                    context("when enabled opt out default") {
                        var event: Event!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (_, _, e) in
                                event = e
                            }
                            let configuration = Configuration { (configuration) in
                                configuration.isOptOut = true
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            
                            module.verify()
                        }
                        
                        it("never sent events") {
                            expect(event).to(beNil())
                        }
                    }
                    
                    context("when set idfa delegate") {
                        var body: TrackBodyParameters!
                        var idfa: IDFA!
                        context("when disable") {
                            beforeEachWithMetadata { (metadata) in
                                idfa = IDFA(isEnabled: false, idfa: "dummy_idfa")
                                let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (_, b, _) in
                                    body = b
                                }
                                let configuration = Configuration { (configuration) in
                                    configuration.idfaDelegate = idfa
                                }
                                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                                
                                module.wait()
                            }
                            
                            it("idfa is nil") {
                                expect(body.appInfo.systemInfo.idfa).to(beNil())
                            }
                        }
                        
                        context("when enable") {
                            beforeEachWithMetadata { (metadata) in
                                idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
                                let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (_, b, _) in
                                    body = b
                                }
                                let configuration = Configuration { (configuration) in
                                    configuration.idfaDelegate = idfa
                                }
                                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                                
                                module.wait()
                            }
                            
                            it("idfa is `dummy_idfa`") {
                                expect(body.appInfo.systemInfo.idfa).to(equal("dummy_idfa"))
                            }
                        }
                    }                    
                }
            }
        }
    }

}
