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
@testable import KarteRemoteNotification



class FCMTokenRegistrarSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = { (request) -> Response in
                let response = TrackResponse(success: 1, status: 200, response: .emptyResponse, error: nil)
                let data = try! createJSONEncoder().encode(response)
                return jsonData(data)(request)
            }
        }
        
        describe("token registrar") {
            context("first time") {
                var event: Event!
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .pluginNativeAppIdentify) { (_, _, e) in
                        event = e
                    }
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    
                    let provider = NotificationSettingsProviderMock()
                    provider.fcmTokenResolver = { "dummy_fcm_token" }
                    provider.availabilityResolver = { true }
                    
                    let registrar = FCMTokenRegistrar(provider)
                    registrar.registerFCMToken()
                    
                    module.wait()
                }
                
                it("event name is `plugin_native_app_identify`") {
                    expect(event.eventName).to(equal(.pluginNativeAppIdentify))
                }
                
                it("values.fcm_token is `dummy_fcm_token`") {
                    expect(event.values.string(forKey: field(.fcmToken))).to(equal("dummy_fcm_token"))
                }
                
                it("values.subscribe is true") {
                    expect(event.values.bool(forKey: field(.subscribe))).to(beTrue())
                }
            }
            
            context("second time") {
                var event: Event!
                
                func runTest(metadata: ExampleMetadata?, fcmToken: String?, subscribe: Bool) -> StubActionModule {
                    event = nil
                    
                    let module1 = StubActionModule(self, metadata: metadata, builder: builder, eventName: .pluginNativeAppIdentify)
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    
                    let provider = NotificationSettingsProviderMock()
                    provider.fcmTokenResolver = { "dummy_fcm_token" }
                    provider.availabilityResolver = { true }
                    
                    let registrar = FCMTokenRegistrar(provider)
                    registrar.registerFCMToken()
                    
                    module1.wait()
                    
                    let module2 = StubActionModule(self, metadata: metadata, builder: builder, eventName: .pluginNativeAppIdentify) { (_, _, e) in
                        event = e
                    }
                    
                    provider.fcmTokenResolver = { fcmToken }
                    provider.availabilityResolver = { subscribe }
                    registrar.registerFCMToken()
                    
                    return module2
                }
                

                context("when the token is updated") {
                    beforeEachWithMetadata { (metadata) in
                        runTest(metadata: metadata, fcmToken: "dummy_fcm_token_2", subscribe: true).wait()
                    }
                    
                    it("event name is `plugin_native_app_identify`") {
                        expect(event.eventName).to(equal(.pluginNativeAppIdentify))
                    }
                    
                    it("values.fcm_token is `dummy_fcm_token_2`") {
                        expect(event.values.string(forKey: field(.fcmToken))).to(equal("dummy_fcm_token_2"))
                    }
                    
                    it("values.subscribe is true") {
                        expect(event.values.bool(forKey: field(.subscribe))).to(beTrue())
                    }
                }
                
                context("when the subscribe is updated") {
                    beforeEachWithMetadata { (metadata) in
                        runTest(metadata: metadata, fcmToken: "dummy_fcm_token", subscribe: false).wait()
                    }
                    
                    it("event name is `plugin_native_app_identify`") {
                        expect(event.eventName).to(equal(.pluginNativeAppIdentify))
                    }
                    
                    it("values.fcm_token is `dummy_fcm_token`") {
                        expect(event.values.string(forKey: field(.fcmToken))).to(equal("dummy_fcm_token"))
                    }
                    
                    it("values.subscribe is false") {
                        expect(event.values.bool(forKey: field(.subscribe))).to(beFalse())
                    }
                }

                context("same settings as before") {
                    beforeEachWithMetadata { (metadata) in
                        runTest(metadata: metadata, fcmToken: "dummy_fcm_token", subscribe: true).verify()
                    }
                    
                    it("event is nil") {
                        expect(event).to(beNil())
                    }
                }
            }
        }
    }
}
