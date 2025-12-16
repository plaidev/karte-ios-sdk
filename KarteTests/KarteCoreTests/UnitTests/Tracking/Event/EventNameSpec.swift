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
@testable import KarteCore

class EventNameSpec: QuickSpec {

    override class func spec() {
        describe("a event name") {
            describe("its initialization event") {
                context("when the event name is native_app_install") {
                    it("is true") {
                        expect(EventName.nativeAppInstall.isInitializationEvent).to(beTrue())
                    }
                }
                context("when the event name is native_app_update") {
                    it("is true") {
                        expect(EventName.nativeAppUpdate.isInitializationEvent).to(beTrue())
                    }
                }
                context("when the event name is native_app_open") {
                    it("is true") {
                        expect(EventName.nativeAppOpen.isInitializationEvent).to(beTrue())
                    }
                }
                context("when the event name is native_app_crashed") {
                    it("is true") {
                        expect(EventName.nativeAppCrashed.isInitializationEvent).to(beTrue())
                    }
                }
                context("when the event name is foo") {
                    it("is false") {
                        expect(EventName("foo").isInitializationEvent).to(beFalse())
                    }
                }
            }
            
            describe("its not user defined event") {
                context("when the event name is view") {
                    it("is true") {
                        expect(EventName.view.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is identify") {
                    it("is true") {
                        expect(EventName.identify.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is attribute") {
                    it("is true") {
                        expect(EventName.attribute
                                .isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_install") {
                    it("is true") {
                        expect(EventName.nativeAppInstall.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_update") {
                    it("is true") {
                        expect(EventName.nativeAppUpdate.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_open") {
                    it("is true") {
                        expect(EventName.nativeAppOpen.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_foreground") {
                    it("is true") {
                        expect(EventName.nativeAppForeground.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_background") {
                    it("is true") {
                        expect(EventName.nativeAppBackground.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_crashed") {
                    it("is true") {
                        expect(EventName.nativeAppCrashed.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_renew_visitor_id") {
                    it("is true") {
                        expect(EventName.nativeAppRenewVisitorId.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is native_app_find_myself") {
                    it("is true") {
                        expect(EventName.nativeFindMyself.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is deep_link_app_open") {
                    it("is true") {
                        expect(EventName.deepLinkAppOpen.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is _message_ready") {
                    it("is true") {
                        expect(EventName.messageReady.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is message_open") {
                    it("is true") {
                        expect(EventName.messageOpen.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is message_close") {
                    it("is true") {
                        expect(EventName.messageClose.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is message_click") {
                    it("is true") {
                        expect(EventName.messageClick.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is _message_suppressed") {
                    it("is true") {
                        expect(EventName.messageSuppressed.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is mass_push_click") {
                    it("is true") {
                        expect(EventName.massPushClick.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is plugin_native_app_identify") {
                    it("is true") {
                        expect(EventName.pluginNativeAppIdentify.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is _fetch_variables") {
                    it("is true") {
                        expect(EventName.fetchVariables.isUserDefinedEvent).to(beFalse())
                    }
                }
                context("when the event name is foo") {
                    it("is false") {
                        expect(EventName("foo").isUserDefinedEvent).to(beTrue())
                    }
                }
            }
            
            describe("its raw value") {
                context("when the event name is view") {
                    it("is `view`") {
                        expect(EventName.view.rawValue).to(equal("view"))
                    }
                }
                context("when the event name is identify") {
                    it("is `identify`") {
                        expect(EventName.identify.rawValue).to(equal("identify"))
                    }
                }
                context("when the event name is attribute") {
                    it("is `attribute`") {
                        expect(EventName.attribute.rawValue).to(equal("attribute"))
                    }
                }
                context("when the event name is nativeAppInstall") {
                    it("is `native_app_install`") {
                        expect(EventName.nativeAppInstall.rawValue).to(equal("native_app_install"))
                    }
                }
                context("when the event name is nativeAppUpdate") {
                    it("is `native_app_install`") {
                        expect(EventName.nativeAppUpdate.rawValue).to(equal("native_app_update"))
                    }
                }
                context("when the event name is nativeAppOpen") {
                    it("is `native_app_open`") {
                        expect(EventName.nativeAppOpen.rawValue).to(equal("native_app_open"))
                    }
                }
                context("when the event name is nativeAppForeground") {
                    it("is `native_app_foreground`") {
                        expect(EventName.nativeAppForeground.rawValue).to(equal("native_app_foreground"))
                    }
                }
                context("when the event name is nativeAppBackground") {
                    it("is `native_app_background`") {
                        expect(EventName.nativeAppBackground.rawValue).to(equal("native_app_background"))
                    }
                }
                context("when the event name is nativeAppCrashed") {
                    it("is `native_app_crashed`") {
                        expect(EventName.nativeAppCrashed.rawValue).to(equal("native_app_crashed"))
                    }
                }
                context("when the event name is nativeAppRenewVisitorId") {
                    it("is `native_app_renew_visitor_id`") {
                        expect(EventName.nativeAppRenewVisitorId.rawValue).to(equal("native_app_renew_visitor_id"))
                    }
                }
                context("when the event name is deepLinkAppOpen") {
                    it("is `deep_link_app_open`") {
                        expect(EventName.deepLinkAppOpen.rawValue).to(equal("deep_link_app_open"))
                    }
                }
                context("when the event name is messageReady") {
                    it("is `_message_ready`") {
                        expect(EventName.messageReady.rawValue).to(equal("_message_ready"))
                    }
                }
                context("when the event name is messageOpen") {
                    it("is `message_open`") {
                        expect(EventName.messageOpen.rawValue).to(equal("message_open"))
                    }
                }
                context("when the event name is messageClose") {
                    it("is `message_close`") {
                        expect(EventName.messageClose.rawValue).to(equal("message_close"))
                    }
                }
                context("when the event name is messageClick") {
                    it("is `message_click`") {
                        expect(EventName.messageClick.rawValue).to(equal("message_click"))
                    }
                }
                context("when the event name is massPushClick") {
                    it("is `mass_push_click`") {
                        expect(EventName.massPushClick.rawValue).to(equal("mass_push_click"))
                    }
                }
                context("when the event name is pluginNativeAppIdentify") {
                    it("is `plugin_native_app_identify`") {
                        expect(EventName.pluginNativeAppIdentify.rawValue).to(equal("plugin_native_app_identify"))
                    }
                }
                context("when the event name is fetchVariables") {
                    it("is `_fetch_variables`") {
                        expect(EventName.fetchVariables.rawValue).to(equal("_fetch_variables"))
                    }
                }
            }
            
            describe("its ==") {
                context("when comparing the same event name") {
                    it("is true") {
                        expect(EventName.nativeAppInstall).to(equal(EventName.nativeAppInstall))
                    }
                }
                context("when comparing the different event name") {
                    it("is false") {
                        expect(EventName.nativeAppInstall).toNot(equal(EventName.nativeAppUpdate))
                    }
                }
            }
            
            describe("its encode") {
                context("when encoding the nativeAppInstall") {
                    it("is `native_app_install`") {
                        let data = try! JSONEncoder().encode(EventName.nativeAppInstall)
                        let eventName = String(data: data, encoding: .utf8)!
                        expect(eventName).to(equal("\"\(EventName.nativeAppInstall.rawValue)\""))
                    }
                }
            }
            
            describe("its decode") {
                context("when decoding the `native_app_install`") {
                    it("is nativeAppInstall") {
                        let data = "\"\(EventName.nativeAppInstall.rawValue)\"".data(using: .utf8)!
                        let eventName = try! JSONDecoder().decode(EventName.self, from: data)
                        expect(eventName).to(equal(EventName.nativeAppInstall))
                    }
                }
            }
        }
    }
}
