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
            describe("its setup with appKey param") {
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
                    
                    it("libraryConfigurations is empty") {
                        let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
                        expect(dummy).to(beNil())
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
                                configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            
                            module.wait()
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                        it("Overlay Base URL is `https://api.karte.io`") {
                            expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
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
                            expect(KarteApp.shared.trackingClient).to(beNil())
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
                    
                    context("when mode is ingest") {
                        var request: URLRequest!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, path: "/v0/native/ingest", builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }
                            let configuration = ExperimentalConfiguration { (configuration) in
                                configuration.operationMode = .ingest
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            
                            module.wait()
                        }
                        
                        it("Request URL is `https://api.karte.io/v0/native/ingest`") {
                            expect(request.url?.absoluteString).to(equal("https://api.karte.io/v0/native/ingest"))
                        }
                    }
                    
                    context("when library config is added") {
                        beforeEachWithMetadata { (metadata) in
                            let configuration = Configuration { (configuration) in
                                configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
                            }
                            KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        }
                        
                        it("libraryConfigurations is not empty") {
                            let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
                            expect(dummy).toNot(beNil())
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
                
                context("when use custom config from plist") {
                    context("when customized base url") {
                        var request: URLRequest!
                        let overwriteAppkey = APP_KEY.uppercased()
                        
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }
                            if let configuration = Configuration.default {
                                configuration.baseURL = URL(string: "https://t.karte.io")!
                                configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                                KarteApp.setup(appKey: overwriteAppkey, configuration: configuration)
                            }
                            
                            module.wait()
                        }
                        
                        it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
                            expect(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(overwriteAppkey))
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                        it("Overlay Base URL is `https://api.karte.io`") {
                            expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
                        }
                    }
                    
                    context("when library config is added") {
                        beforeEachWithMetadata { (metadata) in
                            if let configuration = Configuration.default {
                                configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
                                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            }
                        }
                        
                        it("libraryConfigurations is not empty") {
                            let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
                            expect(dummy).toNot(beNil())
                        }
                    }
                    
                    context("when mode is ingest") {
                        var request: URLRequest!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, path: "/v0/native/ingest", builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }

                            if let configuration = ExperimentalConfiguration.default {
                                configuration.operationMode = .ingest
                                KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                            }

                            module.wait()
                        }

                        it("Request URL is `https://api.karte.io/v0/native/ingest`") {
                            expect(request.url?.absoluteString).to(equal("https://api.karte.io/v0/native/ingest"))
                        }
                    }
                }
            }
            describe("its setup without appKey param") {
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

                        KarteApp.setup()
                        
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
                    
                    it("libraryConfigurations is empty") {
                        let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
                        expect(dummy).to(beNil())
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

                            let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                            if let configuration = Configuration.from(plistPath: path!) {
                                configuration.baseURL = URL(string: "https://t.karte.io")!
                                configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                                KarteApp.setup(configuration: configuration)
                            }
                            
                            module.wait()
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                        it("Overlay Base URL is `https://api.karte.io`") {
                            expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
                        }
                    }
                    
                    context("when enabled dry run") {
                        beforeEach {
                            let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                            if let configuration = Configuration.from(plistPath: path!) {
                                configuration.isDryRun = true
                                KarteApp.setup(configuration: configuration)
                            }
                        }
                        
                        it("tracker is nil") {
                            expect(KarteApp.shared.trackingClient).to(beNil())
                        }
                    }
                    
                    context("when enabled opt out default") {
                        var event: Event!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (_, _, e) in
                                event = e
                            }
                            
                            let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                            if let configuration = Configuration.from(plistPath: path!) {
                                configuration.isOptOut = true
                                KarteApp.setup(configuration: configuration)
                            }
                            
                            module.verify()
                        }
                        
                        it("never sent events") {
                            expect(event).to(beNil())
                        }
                    }
                    
                    context("when mode is ingest") {
                        var request: URLRequest!
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, path: "/v0/native/ingest", builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }
                            
                            let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                            if let configuration = ExperimentalConfiguration.from(plistPath: path!) {
                                configuration.operationMode = .ingest
                                KarteApp.setup(configuration: configuration)
                            }
                            
                            module.wait()
                        }
                        
                        it("Request URL is `https://api.karte.io/v0/native/ingest`") {
                            expect(request.url?.absoluteString).to(equal("https://api.karte.io/v0/native/ingest"))
                        }
                    }
                    
                    context("when library config is added") {
                        beforeEachWithMetadata { (metadata) in
                            let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                            if let configuration = Configuration.from(plistPath: path!) {
                                configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
                                KarteApp.setup(configuration: configuration)
                            }
                        }
                        
                        it("libraryConfigurations is not empty") {
                            let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
                            expect(dummy).toNot(beNil())
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
                                
                                let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                                if let configuration = ExperimentalConfiguration.from(plistPath: path!) {
                                    configuration.idfaDelegate = idfa
                                    KarteApp.setup(configuration: configuration)
                                }
                                
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
                                
                                let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-mock-Info", ofType: "plist")
                                if let configuration = ExperimentalConfiguration.from(plistPath: path!) {
                                    configuration.idfaDelegate = idfa
                                    KarteApp.setup(configuration: configuration)
                                }
                                
                                module.wait()
                            }
                            
                            it("idfa is `dummy_idfa`") {
                                expect(body.appInfo.systemInfo.idfa).to(equal("dummy_idfa"))
                            }
                        }
                    }
                }
                
                context("when use custom config without plist") {
                    context("when customized base url with configurator") {
                        var request: URLRequest!
                        let overwriteAppKey = APP_KEY.uppercased()
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }

                            let configuration = Configuration { (configuration) in
                                configuration.appKey = overwriteAppKey
                                configuration.baseURL = URL(string: "https://t.karte.io")!
                                configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                            }
                            KarteApp.setup(configuration: configuration)
                            
                            module.wait()
                        }
                        
                        it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
                            expect(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(overwriteAppKey))
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                        it("Overlay Base URL is `https://api.karte.io`") {
                            expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
                        }
                    }
                    
                    context("when customized base url with initializer") {
                        var request: URLRequest!
                        let overwriteAppKey = APP_KEY.uppercased()
                        beforeEachWithMetadata { (metadata) in
                            let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (r, _, _) in
                                request = r
                            }

                            let configuration = Configuration(appKey: overwriteAppKey)
                            configuration.appKey = overwriteAppKey
                            configuration.baseURL = URL(string: "https://t.karte.io")!
                            configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                            KarteApp.setup(configuration: configuration)
                            
                            module.wait()
                        }
                        
                        it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
                            expect(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(overwriteAppKey))
                        }
                        
                        it("Request URL is `https://t.karte.io/v0/native/track`") {
                            expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
                        }
                        it("Overlay Base URL is `https://api.karte.io`") {
                            expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
                        }
                    }
                }
            }
        }
    }

}
