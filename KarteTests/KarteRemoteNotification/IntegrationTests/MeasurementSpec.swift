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

class UserInfoBuilder {
    var isPushNotificationEnabled = true
    var isMassPushNotificationEnabled = false
    var campaignId = "dummy_campaign_id"
    var shortenId = "dummy_shorten_id"
    var url: String? = "https://karte.io"
    
    func setPushNotification(_ isEnabled: Bool) -> UserInfoBuilder {
        self.isPushNotificationEnabled = isEnabled
        self.isMassPushNotificationEnabled = !isEnabled
        return self
    }
    
    func setMassPushNotification(_ isEnabled: Bool) -> UserInfoBuilder {
        self.isPushNotificationEnabled = !isEnabled
        self.isMassPushNotificationEnabled = isEnabled
        return self
    }
    
    func setCampaignId(_ campaignId: String) -> UserInfoBuilder {
        self.campaignId = campaignId
        return self
    }
    
    func setShortenId(_ shortenId: String) -> UserInfoBuilder {
        self.shortenId = shortenId
        return self
    }
    
    func setURL(_ url: String?) -> UserInfoBuilder {
        self.url = url
        return self
    }
    
    func build() -> [AnyHashable: Any] {
        var userInfo: [AnyHashable: Any] = [
            "krt_campaign_id": campaignId,
            "krt_shorten_id": shortenId,
            "krt_event_values": "{\"v\": true}",
        ]
        if isPushNotificationEnabled {
            userInfo["krt_push_notification"] = true
        }
        if isMassPushNotificationEnabled {
            userInfo["krt_mass_push_notification"] = true
        }
        if let url = url {
            userInfo["krt_attributes"] = "{\"url\":\"\(url)\"}"
        } else {
            userInfo["krt_attributes"] = "{}"
        }
        return userInfo
    }
}


class MeasurementSpec: QuickSpec {
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .empty).build()
        }

        describe("a measurement") {
            describe("a track") {
                context("from default") {
                    var event: Event!
                    
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .messageClick) { (_, _, e) in
                            event = e
                        }
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        
                        let userInfo = UserInfoBuilder().build()
                        let notification = RemoteNotification(userInfo: userInfo)!
                        notification.track()
                        
                        module.wait()
                    }
                    
                    it("event name is `message_click`") {
                        expect(event.eventName).to(equal(.messageClick))
                    }
                    
                    it("values.message.campaign_id is `dummy_campaign_id`") {
                        expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("dummy_campaign_id"))
                    }
                    
                    it("values.message.shorten_id is `dummy_shorten_id`") {
                        expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("dummy_shorten_id"))
                    }
                    
                    it("values.v is true") {
                        expect(event.values.bool(forKey: "v")).to(beTrue())
                    }
                }
                
                context("from masspush") {
                    var event: Event!
                    
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .massPushClick) { (_, _, e) in
                            event = e
                        }
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        
                        let userInfo = UserInfoBuilder().setMassPushNotification(true).build()
                        let notification = RemoteNotification(userInfo: userInfo)!
                        notification.track()
                        
                        module.wait()
                    }
                    
                    it("event name is `mass_push_click`") {
                        expect(event.eventName).to(equal(.massPushClick))
                    }
                    
                    it("values.message.campaign_id is nil") {
                        expect(event.values.string(forKeyPath: "message.campaign_id")).to(beNil())
                    }
                    
                    it("values.message.shorten_id is nil") {
                        expect(event.values.string(forKeyPath: "message.shorten_id")).to(beNil())
                    }
                    
                    it("values.v is true") {
                        expect(event.values.bool(forKey: "v")).to(beTrue())
                    }
                }
            }
            
            describe("a url") {
                context("url is valid") {
                    let userInfo = UserInfoBuilder().build()
                    let notification = RemoteNotification(userInfo: userInfo)!
                    
                    it("url is `https://karte.io`") {
                        expect(notification.url?.absoluteString).to(equal("https://karte.io"))
                    }
                }
                
                context("url is not valid") {
                    let userInfo = UserInfoBuilder().setURL("NOT URL!!!").build()
                    let notification = RemoteNotification(userInfo: userInfo)!
                    
                    it("url is nil") {
                        expect(notification.url).to(beNil())
                    }
                }
                
                context("url is not contain") {
                    let userInfo = UserInfoBuilder().setURL(nil).build()
                    let notification = RemoteNotification(userInfo: userInfo)!
                    
                    it("url is nil") {
                        expect(notification.url).to(beNil())
                    }
                }
            }
        }
    }
}
