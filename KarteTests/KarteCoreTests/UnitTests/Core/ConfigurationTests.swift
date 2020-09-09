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

class ConfigurationSpec: QuickSpec {

    override func spec() {
        describe("a configuration") {
            context("when use default configuration") {
                var configuration: KarteCore.Configuration!
                
                beforeSuite {
                    configuration = KarteCore.Configuration.defaultConfiguration
                }
                
                it("baseURL is `https://api.karte.io`") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://api.karte.io"))
                }
                
                it("overlayBaseURL is `https://cf-native.karte.io`") {
                    expect(configuration.overlayBaseURL.absoluteString).to(equal("https://cf-native.karte.io"))
                }
                
                it("logCollectionURL is `https://us-central1-production-debug-log-collector.cloudfunctions.net/nativeAppLogUrl`") {
                    expect(configuration.logCollectionURL.absoluteString).to(equal("https://us-central1-production-debug-log-collector.cloudfunctions.net/nativeAppLogUrl"))
                }
                
                it("isDryRun is false") {
                    expect(configuration.isDryRun).to(beFalse())
                }
                
                it("isOptOut is false") {
                    expect(configuration.isOptOut).to(beFalse())
                }
                
                it("isEnabledSendInitializationEvent is true") {
                    expect(configuration.isSendInitializationEventEnabled).to(beTrue())
                }
                
                it("IDFADelegate is nil") {
                    expect(configuration.idfaDelegate).to(beNil())
                }
            }
            
            context("when use custom configuration") {
                var configuration: KarteCore.Configuration!
                var idfa: IDFA!
                
                beforeSuite {
                    idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
                    configuration = KarteCore.Configuration { (configuration) in
                        configuration.baseURL = URL(string: "https://example.com")!
                        configuration.overlayBaseURL = URL(string: "https://example.com")!
                        configuration.logCollectionURL = URL(string: "https://example.com")!
                        configuration.isDryRun = true
                        configuration.isOptOut = true
                        configuration.isSendInitializationEventEnabled = false
                        configuration.idfaDelegate = idfa
                    }
                }
                
                it("baseURL is `https://example.com`") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://example.com"))
                }
                
                it("overlayBaseURL is `https://example.com`") {
                    expect(configuration.overlayBaseURL.absoluteString).to(equal("https://example.com"))
                }
                
                it("logCollectionURL is `https://example.com`") {
                    expect(configuration.logCollectionURL.absoluteString).to(equal("https://example.com"))
                }
                
                it("isDryRun is true") {
                    expect(configuration.isDryRun).to(beTrue())
                }
                
                it("isOptOut is true") {
                    expect(configuration.isOptOut).to(beTrue())
                }
                
                it("isEnabledSendInitializationEvent is false") {
                    expect(configuration.isSendInitializationEventEnabled).to(beFalse())
                }
                
                it("IDFADelegate is not nil") {
                    expect(configuration.idfaDelegate).toNot(beNil())
                }
                
                it("isAdvertisingTrackingEnabled is true") {
                    expect(configuration.idfaDelegate!.isAdvertisingTrackingEnabled).to(beTrue())
                }
                
                it("advertisingIdentifierString is `dummy_idfa`") {
                    expect(configuration.idfaDelegate!.advertisingIdentifierString).to(equal("dummy_idfa"))
                }
            }
        }
    }
}
