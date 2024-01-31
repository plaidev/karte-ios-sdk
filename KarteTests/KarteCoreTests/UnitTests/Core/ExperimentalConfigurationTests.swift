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

class ExperimentalConfigurationTestsSpec: QuickSpec {

    override func spec() {
        describe("a configuration") {
            context("when use default configuration") {
                var configuration: KarteCore.ExperimentalConfiguration!
                
                beforeSuite {
                    configuration = KarteCore.ExperimentalConfiguration.defaultConfiguration
                }
                
                it("appKey is empty text") {
                    expect(configuration.appKey).to(beEmpty())
                }
                
                it("apiKey is empty text") {
                    expect(configuration.apiKey).to(beEmpty())
                }
                
                it("baseURL is `https://b.karte.io`") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://b.karte.io"))
                }
                
                it("dataLocation is `tw`") {
                    expect(configuration.dataLocation).to(equal("tw"))
                }
                
                it("overlayBaseURL is `https://cf-native.karte.io`") {
                    expect(configuration.overlayBaseURL.absoluteString).to(equal("https://cf-native.karte.io"))
                }
                
                it("isDryRun is false") {
                    expect(configuration.isDryRun).to(beFalse())
                }
                
                it("isOptOut is false") {
                    expect(configuration.isOptOut).to(beFalse())
                }
                
                it("mode is normal") {
                    expect(configuration.operationMode).to(equal(.default))
                }
                
                it("isEnabledSendInitializationEvent is true") {
                    expect(configuration.isSendInitializationEventEnabled).to(beTrue())
                }
                
                it("libraryConfigrations is empty") {
                    expect(configuration.libraryConfigurations).to(beEmpty())
                }
                
                it("IDFADelegate is nil") {
                    expect(configuration.idfaDelegate).to(beNil())
                }
            }
            
            context("when use custom configuration") {
                var configuration: KarteCore.ExperimentalConfiguration!
                var idfa: IDFA!
                
                beforeSuite {
                    idfa = IDFA(isEnabled: true, idfa: "dummy_idfa")
                    configuration = KarteCore.ExperimentalConfiguration { (configuration) in
                        configuration.appKey = "dummy_application_key"
                        configuration.apiKey = "dummy_api_key"
                        configuration.baseURL = URL(string: "https://example.com")!
                        configuration.dataLocation = "jp"
                        configuration.overlayBaseURL = URL(string: "https://example.com")!
                        configuration.isDryRun = true
                        configuration.isOptOut = true
                        configuration.operationMode = .ingest
                        configuration.isSendInitializationEventEnabled = false
                        configuration.libraryConfigurations = [DummyLibraryConfiguration(name: "dummy")]
                        configuration.idfaDelegate = idfa
                    }
                }
                
                it("appKey is `dummy_application_key`") {
                    expect(configuration.appKey).to(equal("dummy_application_key"))
                }
                
                it("apiKey is `dummy_api_key`") {
                    expect(configuration.apiKey).to(equal("dummy_api_key"))
                }
                
                it("baseURL is `https://example.com`") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://example.com"))
                }
                
                it("dataLocation is `jp`") {
                    expect(configuration.dataLocation).to(equal("jp"))
                }
                
                it("overlayBaseURL is `https://example.com`") {
                    expect(configuration.overlayBaseURL.absoluteString).to(equal("https://example.com"))
                }
                
                it("isDryRun is true") {
                    expect(configuration.isDryRun).to(beTrue())
                }
                
                it("isOptOut is true") {
                    expect(configuration.isOptOut).to(beTrue())
                }
                
                it("mode is ingest") {
                    expect(configuration.operationMode).to(equal(.ingest))
                }
                
                it("isEnabledSendInitializationEvent is false") {
                    expect(configuration.isSendInitializationEventEnabled).to(beFalse())
                }
                
                it("libraryConfiguration is not empty") {
                    expect(configuration.libraryConfigurations).toNot(beEmpty())
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
            
            context("when read from plist") {
                var configuration: KarteCore.ExperimentalConfiguration!
                
                beforeSuite {
                    let path = Bundle(for: SetupSpec.self).path(forResource: "Karte-custom-Info", ofType: "plist")
                    configuration = KarteCore.ExperimentalConfiguration.from(plistPath: path!)
                }
                
                it("appKey is `dummy_application_key_customized`") {
                    expect(configuration.appKey).to(equal("dummy_application_key_customized"))
                }
                
                it("apiKey is `dummy_karte_api_key`") {
                    expect(configuration.apiKey).to(equal("dummy_karte_api_key"))
                }
                
                it("baseURL is `https://b-jp.karte.io`") {
                    expect(configuration.baseURL.absoluteString).to(equal("https://b-jp.karte.io"))
                }
                
                it("dataLocation is `jp`") {
                    expect(configuration.dataLocation).to(equal("jp"))
                }
                
                it("overlayBaseURL is `https://cf-native.karte.io`") {
                    expect(configuration.overlayBaseURL.absoluteString).to(equal("https://cf-native.karte.io"))
                }
                
                it("isDryRun is false") {
                    expect(configuration.isDryRun).to(beFalse())
                }
                
                it("isOptOut is false") {
                    expect(configuration.isOptOut).to(beFalse())
                }
                
                it("mode is normal") {
                    expect(configuration.operationMode).to(equal(.default))
                }
                
                it("isEnabledSendInitializationEvent is true") {
                    expect(configuration.isSendInitializationEventEnabled).to(beTrue())
                }
                
                it("libraryConfigrations is empty") {
                    expect(configuration.libraryConfigurations).to(beEmpty())
                }
                
                it("IDFADelegate is nil") {
                    expect(configuration.idfaDelegate).to(beNil())
                }
            }
        }
    }
}
