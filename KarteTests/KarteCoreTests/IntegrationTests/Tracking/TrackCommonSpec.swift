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

class TrackCommonSpec: QuickSpec {
    
    override func spec() {
        var idfa: IDFA!
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            idfa = IDFA()
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
                configuration.idfaDelegate = idfa
            }
            builder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("a tracker") {
            describe("its track common") {
                var body: TrackBodyParameters!
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: builder)
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                    let event = Event(eventName: EventName("test"))
                    Tracker.track(event: event)
                    
                    body = module.wait().body(EventName("test"))
                }
                
                it("keys.visitor_id is `dummy_visitor_id`") {
                    expect(body.keys.visitorId).to(equal("dummy_visitor_id"))
                }
                
                it("keys.pv_id is `dummy_pv_id`") {
                    expect(body.keys.pvId.identifier).to(equal("dummy_pv_id"))
                }
                
                it("keys.original_pv_id is `dummy_original_pv_id`") {
                    expect(body.keys.originalPvId.identifier).to(equal("dummy_original_pv_id"))
                }
                
                it("app_info.version_name is `1.0.0`") {
                    expect(body.appInfo.versionName).to(equal("1.0.0"))
                }
                
                it("app_info.version_code is `1`") {
                    expect(body.appInfo.versionCode).to(equal("1"))
                }
                
                it("app_info.karte_sdk_version is `1.0.0`") {
                    expect(body.appInfo.karteSdkVersion).to(equal("1.0.0"))
                }
                
                it("app_info.module_info.core is `2.0.0`") {
                    expect(body.appInfo.moduleInfo["core"]).to(equal("2.0.0"))
                }
                
                it("app_info.module_info.in_app_messaging is `2.0.0`") {
                    expect(body.appInfo.moduleInfo["in_app_messaging"]).to(equal("2.0.0"))
                }
                
                it("app_info.system_info.os is `iOS`") {
                    expect(body.appInfo.systemInfo.os).to(equal("iOS"))
                }
                
                it("app_info.system_info.os_version is `13.0`") {
                    expect(body.appInfo.systemInfo.osVersion).to(equal("13.0"))
                }
                
                it("app_info.system_info.device is `iPhone`") {
                    expect(body.appInfo.systemInfo.device).to(equal("iPhone"))
                }
                
                it("app_info.system_info.model is `iPhone10,3`") {
                    expect(body.appInfo.systemInfo.model).to(equal("iPhone10,3"))
                }
                
                it("app_info.system_info.bundle_id is `io.karte`") {
                    expect(body.appInfo.systemInfo.bundleId).to(equal("io.karte"))
                }
                
                it("app_info.system_info.language is `ja-JP`") {
                    expect(body.appInfo.systemInfo.language).to(equal("ja-JP"))
                }
                
                it("app_info.system_info.idfv is `dummy_idfv`") {
                    expect(body.appInfo.systemInfo.idfv).to(equal("dummy_idfv"))
                }
                
                it("app_info.system_info.idfa is `dummy_idfa`") {
                    expect(body.appInfo.systemInfo.idfa).to(equal("dummy_idfa"))
                }
                
                it("app_info.system_info.screen.width is 375") {
                    expect(body.appInfo.systemInfo.screen.width).to(equal(375))
                }
                
                it("app_info.system_info.screen.height is 812") {
                    expect(body.appInfo.systemInfo.screen.height).to(equal(812))
                }
            }
        }
    }
}
