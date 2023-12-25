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
import Foundation

typealias ResolvedConfigurationContext = (request: URLRequest, body: TrackBodyParameters, events: [Event])
class ResolvedConfigurationBehavior : Behavior<ResolvedConfigurationContext> {
    override class func spec(_ context: @escaping () -> ResolvedConfigurationContext) {
        var ctx: ResolvedConfigurationContext!
        beforeEach {
            ctx = context()
        }
        it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
            expect(ctx.request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(APP_KEY))
        }
        
        it("Request Header contains `Content-Encoding: gzip`") {
            expect(ctx.request.allHTTPHeaderFields!["Content-Encoding"]!).to(equal("gzip"))
        }
        
        it("Request URL is `https://api.karte.io/v0/native/track`") {
            expect(ctx.request.url!.absoluteString).to(equal("https://api.karte.io/v0/native/track"))
        }
        
        it("occurred native_app_open event") {
            let contain = ctx.events.contains(where: { $0.eventName == .nativeAppOpen })
            expect(contain).to(beTrue())
        }
        
        it("occurred native_app_install event") {
            let contain = ctx.events.contains(where: { $0.eventName == .nativeAppInstall })
            expect(contain).to(beTrue())
        }
        
        it("libraryConfigurations is empty") {
            let dummy: DummyLibraryConfiguration? = KarteApp.shared.libraryConfiguration()
            expect(dummy).to(beNil())
        }
        
        it("apiKey is empty") {
            expect(KarteApp.shared.configuration.apiKey).to(beEmpty())
        }
        
        it("idfa is nil") {
            expect(ctx.body.appInfo.systemInfo.idfa).to(beNil())
        }
    }
}

typealias CustomConfigurationContext = (spec: QuickSpec, builder: Builder, setup: ((Configuration) -> Void) -> Void, setupExp: ((ExperimentalConfiguration) -> Void) -> Void, expectAppKey: String, expectApiKey: String)
class CustomConfigurationBaseBehavior : Behavior<CustomConfigurationContext> {
    override class func spec(_ aContext: @escaping () -> CustomConfigurationContext) {
        var ctx: CustomConfigurationContext!
        beforeEach {
            ctx = aContext()
        }
        
        context("when customized base url") {
            var request: URLRequest!
            beforeEachWithMetadata { (metadata) in
                let module = StubActionModule(ctx.spec, metadata: metadata, builder: ctx.builder)
                ctx.setup { configuration in
                    configuration.baseURL = URL(string: "https://t.karte.io")!
                    configuration.overlayBaseURL = URL(string: "https://api.karte.io")!
                }
                
                request = module.wait().request(.nativeAppOpen)
            }
            
            it("Request Header contains `X-KARTE-App-Key: dummy_app_key`") {
                expect(request.allHTTPHeaderFields!["X-KARTE-App-Key"]!).to(equal(ctx.expectAppKey))
            }
            
            it("Request URL is `https://t.karte.io/v0/native/track`") {
                expect(request.url?.absoluteString).to(equal("https://t.karte.io/v0/native/track"))
            }
            it("Overlay Base URL is `https://api.karte.io`") {
                expect(KarteApp.shared.configuration.overlayBaseURL.absoluteString).to(equal("https://api.karte.io"))
            }
            it("apiKey is `dummy_api_key`") {
                expect(KarteApp.shared.configuration.apiKey).to(equal(ctx.expectApiKey))
            }
        }
    }
}
class CustomConfigurationOtherBehavior : Behavior<CustomConfigurationContext> {
    override class func spec(_ aContext: @escaping () -> CustomConfigurationContext) {
        var ctx: CustomConfigurationContext!

        beforeEach {
            Thread.sleep(forTimeInterval: 1)

            ctx = aContext()
        }

        context("when enabled dry run") {
            beforeEach {
                ctx.setup { configuration in
                    configuration.isDryRun = true
                }
            }
            
            it("tracker is nil") {
                expect(KarteApp.shared.trackingClient).to(beNil())
            }
        }
        
        context("when enabled opt out default") {
            var event: Event!
            beforeEachWithMetadata { (metadata) in
                let module = StubActionModule(ctx.spec, metadata: metadata, builder: ctx.builder)
                ctx.setup { configuration in
                    configuration.isOptOut = true
                }
                
                module.verify()
                event = module.event(.nativeAppOpen)
            }
            
            it("never sent events") {
                expect(event).to(beNil())
            }
        }
        
        context("when mode is ingest") {
            var request: URLRequest!
            beforeEachWithMetadata { (metadata) in
                let module = StubActionModule(ctx.spec, metadata: metadata, path: "/v0/native/ingest", builder: ctx.builder)
                ctx.setupExp { configuration in
                    configuration.operationMode = .ingest
                }
                
                request = module.wait().request(.nativeAppOpen)
            }
            
            it("Request URL is `https://api.karte.io/v0/native/ingest`") {
                expect(request.url?.absoluteString).to(equal("https://api.karte.io/v0/native/ingest"))
            }
        }
        
        context("when library config is added") {
            beforeEachWithMetadata { (metadata) in
                ctx.setup { configuration in
                    configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
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
                    let module = StubActionModule(ctx.spec, metadata: metadata, builder: ctx.builder)
                    ctx.setup { configuration in
                        configuration.idfaDelegate = idfa
                    }
                    
                    body = module.wait().body(.nativeAppOpen)
                }
                
                it("idfa is nil") {
                    expect(body.appInfo.systemInfo.idfa).to(beNil())
                }
            }
            
            context("when enable") {
                beforeEachWithMetadata { (metadata) in
                    idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
                    let module = StubActionModule(ctx.spec, metadata: metadata, builder: ctx.builder)
                    ctx.setup { configuration in
                        configuration.idfaDelegate = idfa
                    }
                    
                    body = module.wait().body(.nativeAppOpen)
                }
                
                it("idfa is `dummy_idfa`") {
                    expect(body.appInfo.systemInfo.idfa).to(equal("dummy_idfa"))
                }
            }
        }
    }
}

let APP_KEY_OVERWRITED = APP_KEY.uppercased()
let APP_KEY_FROM_PLIST = "dummy_application_key_from_plist"
let APP_KEY_FROM_CUSTOM = "dummy_application_key_customized"
let API_KEY = "dummy_api_key"
let API_KEY_FROM_CUSTOM = "dummy_karte_api_key"

class SetupSpec: QuickSpec {
    
    override func spec() {
        var builder: Builder!
        
        beforeSuite {
            builder = StubBuilder(spec: self, resource: .empty).build()
        }

        describe("a karte app") {
            describe("its setup with appKey param") {
                context("when use default config(from resolver)") {
                    var request: URLRequest!
                    var body: TrackBodyParameters!
                    var events: [Event] = []
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: builder)

                        KarteApp.setup(appKey: APP_KEY)
                        
                        module.wait().responseDatas([.nativeAppOpen, .nativeAppInstall]).forEach { data in
                            request = data.request
                            body = data.body
                            events.append(data.event)
                        }
                    }
                    itBehavesLike(ResolvedConfigurationBehavior.self) { (request, body, events) }
                }
                
                context("when use custom config from default plist") {
                    let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                        let config = Configuration.default!
                        configure(config)
                        KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                    }, setupExp: { configure in
                        let config = ExperimentalConfiguration.default!
                        configure(config)
                        KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                    }, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: "") }
                    itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    itBehavesLike(CustomConfigurationOtherBehavior.self, context: ctx)
                }
                
                context("when use custom config from custom plist") {
                    let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-custom-Info", ofType: "plist")
                    let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                        let config = Configuration.from(plistPath: path!)!
                        configure(config)
                        KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                    }, setupExp: { configure in
                        let config = ExperimentalConfiguration.from(plistPath: path!)!
                        configure(config)
                        KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                    }, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: API_KEY_FROM_CUSTOM) }
                    itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    itBehavesLike(CustomConfigurationOtherBehavior.self, context: ctx)
                }
                
                context("when use custom config without plist") {
                    context("without appkey") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration()
                            configure(config)
                            KarteApp.setup(appKey: APP_KEY, configuration: config)
                        }, setupExp: { configure in
                            let config = ExperimentalConfiguration()
                            configure(config)
                            KarteApp.setup(appKey: APP_KEY, configuration: config)
                        }, expectAppKey: APP_KEY, expectApiKey: "") }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                        itBehavesLike(CustomConfigurationOtherBehavior.self, context: ctx)
                    }
                    context("with appkey by setter") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration()
                            config.appKey = APP_KEY
                            config.apiKey = API_KEY
                            configure(config)
                            KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: API_KEY) }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                    
                    context("with appkey by configurator") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration { (configuration) in
                                configuration.appKey = APP_KEY
                            }
                            configure(config)
                            KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: "") }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                    
                    context("with appkey by initializer") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration(appKey: APP_KEY)
                            configure(config)
                            KarteApp.setup(appKey: APP_KEY_OVERWRITED, configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY_OVERWRITED, expectApiKey: "") }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                }
            }
            describe("its setup without appKey param") {
                context("when use default config(from resolver)") {
                    var request: URLRequest!
                    var body: TrackBodyParameters!
                    var events: [Event] = []
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: builder)

                        KarteApp.setup()
                        
                        module.wait().responseDatas([.nativeAppOpen, .nativeAppInstall]).forEach { data in
                            request = data.request
                            body = data.body
                            events.append(data.event)
                        }
                    }
                    itBehavesLike(ResolvedConfigurationBehavior.self) { (request, body, events) }
                }
                
                context("when use custom config from default plist") {
                    let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                        let config = Configuration.default!
                        configure(config)
                        KarteApp.setup(configuration: config)
                    }, setupExp: { configure in
                        let config = ExperimentalConfiguration.default!
                        configure(config)
                        KarteApp.setup(configuration: config)
                    }, expectAppKey: APP_KEY_FROM_PLIST, expectApiKey: "") }
                    itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    itBehavesLike(CustomConfigurationOtherBehavior.self, context: ctx)
                }
                
                context("when use custom config from custom plist") {
                    let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-custom-Info", ofType: "plist")
                    let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                        let config = Configuration.from(plistPath: path!)!
                        configure(config)
                        KarteApp.setup(configuration: config)
                    }, setupExp: { configure in
                        let config = ExperimentalConfiguration.from(plistPath: path!)!
                        configure(config)
                        KarteApp.setup(configuration: config)
                    }, expectAppKey: APP_KEY_FROM_CUSTOM, expectApiKey: API_KEY_FROM_CUSTOM) }
                    itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    itBehavesLike(CustomConfigurationOtherBehavior.self, context: ctx)
                }
                
                context("when use custom config without plist") {
                    context("without appkey") {
                        it("throw assertion") {
                            expect { KarteApp.setup(configuration: Configuration()) }.to(throwAssertion())
                        }
                    }
                    
                    context("with appkey by setter") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration()
                            config.appKey = APP_KEY
                            config.apiKey = API_KEY
                            configure(config)
                            KarteApp.setup(configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY, expectApiKey: API_KEY) }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                    
                    context("with appkey by configurator") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration { (configuration) in
                                configuration.appKey = APP_KEY
                            }
                            configure(config)
                            KarteApp.setup(configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY, expectApiKey: "") }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                    
                    context("with appkey by initializer") {
                        let ctx: () -> CustomConfigurationContext = { (spec: self, builder: builder, setup: { configure in
                            let config = Configuration(appKey: APP_KEY)
                            configure(config)
                            KarteApp.setup(configuration: config)
                        }, setupExp: { configure in
                        }, expectAppKey: APP_KEY, expectApiKey: "") }
                        itBehavesLike(CustomConfigurationBaseBehavior.self, context: ctx)
                    }
                }
            }
        }
    }

}
