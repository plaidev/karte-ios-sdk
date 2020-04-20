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

class OptOutConfigSpec: QuickSpec {

    override func spec() {
        describe("a optout config") {
            var configuration: KarteCore.Configuration!
            
            context("Configuration.isOptOut is true") {
                beforeEach {
                    UserDefaults.standard.removeObject(forKey: .optout)
                    configuration = Configuration { (config) in
                        config.isOptOut = true
                    }
                }
                
                context("when not set optout") {
                    it("isOptOut is true") {
                        let service = OptOutService(configuration: configuration)
                        expect(service.isOptOut).to(beTrue())
                    }
                }
                
                context("when set optout") {
                    it("isOptOut is true") {
                        let service = OptOutService(configuration: configuration)
                        service.optOut()
                        
                        expect(service.isOptOut).to(beTrue())
                    }
                }
                
                context("when set optouttemporarily") {
                    it("isOptOut is true") {
                        let service = OptOutService(configuration: configuration)
                        service.optOutTemporarily()
                        
                        expect(service.isOptOut).to(beTrue())
                    }
                }

                context("when set optin") {
                    it("isOptOut is false") {
                        let service = OptOutService(configuration: configuration)
                        service.optIn()
                        
                        expect(service.isOptOut).to(beFalse())
                    }
                }
            }
            
            context("Configuration.isOptOut is false") {
                beforeEach {
                    UserDefaults.standard.removeObject(forKey: .optout)
                    configuration = Configuration { (config) in
                        config.isOptOut = false
                    }
                }
                
                context("when not set optout") {
                    it("isOptOut is false") {
                        let service = OptOutService(configuration: configuration)
                        expect(service.isOptOut).to(beFalse())
                    }
                }
                
                context("when set optout") {
                    it("isOptOut is true") {
                        let service = OptOutService(configuration: configuration)
                        service.optOut()
                        
                        expect(service.isOptOut).to(beTrue())
                    }
                }
                
                context("when set optouttemporarily") {
                    it("isOptOut is true") {
                        let service = OptOutService(configuration: configuration)
                        service.optOutTemporarily()
                        
                        expect(service.isOptOut).to(beTrue())
                    }
                }

                context("when set optin") {
                    it("isOptOut is false") {
                        let service = OptOutService(configuration: configuration)
                        service.optIn()
                        
                        expect(service.isOptOut).to(beFalse())
                    }
                }
            }
        }
    }
}
