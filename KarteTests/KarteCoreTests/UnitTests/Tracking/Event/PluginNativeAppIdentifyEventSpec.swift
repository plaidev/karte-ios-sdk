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
@testable import KarteRemoteNotification

class PluginNativeAppIdentifyEventSpec: QuickSpec {
    
    override func spec() {
        describe("a plugin native app identify event") {
            var event: Event!
            
            context("when fcmToken is not nil and subscribe is true") {
                beforeEach {
                    event = Event(.pluginNativeAppIdentify(subscribe: true, fcmToken: "fcm_token"))
                }
                
                describe("its eventName") {
                    it("is pluginNativeAppIdentify") {
                        expect(event.eventName).to(equal(.pluginNativeAppIdentify))
                    }
                }
                
                describe("its values") {
                    it("is not nil") {
                        expect(event.values).toNot(beNil())
                    }
                }
                
                describe("its build values") {
                    it("count is 2") {
                        expect(event.values.count).to(equal(2))
                    }
                    
                    it("values.fcm_token is `fcm_token`") {
                        expect(event.values.string(forKey: "fcm_token")).to(equal("fcm_token"))
                    }
                    
                    it("values.subscribe is `true`") {
                        expect(event.values.bool(forKey: "subscribe")).to(beTrue())
                    }
                }
            }
            
            context("when subscribe is false") {
                beforeEach {
                    event = Event(.pluginNativeAppIdentify(subscribe: false, fcmToken: nil))
                }
                
                describe("its build values") {
                    it("count is 1") {
                        expect(event.values.count).to(equal(1))
                    }
                    
                    it("values.subscribe is `false`") {
                        expect(event.values.bool(forKey: "subscribe")).to(beFalse())
                    }
                }
            }
        }
    }
}
