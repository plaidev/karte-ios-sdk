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
import KarteUtilities
@testable import KarteCore

class VisitorIdServiceSpec: QuickSpec {

    override func spec() {
        var visitorIdGeneratorMock: VisitorIdGeneratorMock!
        
        beforeEach {
            visitorIdGeneratorMock = VisitorIdGeneratorMock()
            
            Resolver.root = Resolver.submock
            Resolver.root.register(name: "visitor_id_service.generator") {
                visitorIdGeneratorMock as IdGenerator
            }
        }
        
        afterEach {
            Resolver.root = Resolver.mock
            VisitorIdService().clean()
        }
        
        describe("its initialize") {
            var service: VisitorIdService!
            
            beforeEach {
                service = VisitorIdService()
            }
            
            it("visitor_id is `dummy_visitor_id`") {
                expect(service.visitorId).to(equal("dummy_visitor_id"))
            }
            
            it("stored visitor_id is `dummy_visitor_id`") {
                let service = VisitorIdService()
                expect(service.visitorId).to(equal("dummy_visitor_id"))
            }
        }
        
        describe("its renew") {
            var service: VisitorIdService!
            
            beforeEach {
                // Generate new visitor_id
                _ = VisitorIdService().visitorId
                
                visitorIdGeneratorMock.id = "renew_visitor_id"
                
                service = VisitorIdService()
                service.renew()
            }
            
            it("visitor_id is `renew_visitor_id`") {
                expect(service.visitorId).to(equal("renew_visitor_id"))
            }
            
            it("stored visitor_id is `renew_visitor_id`") {
                let service = VisitorIdService()
                expect(service.visitorId).to(equal("renew_visitor_id"))
            }
        }
        
        describe("its delete") {
            beforeEach {
                Resolver.root = Resolver.main
            }
            
            afterEach {
                Resolver.root = Resolver.mock
            }
            
            it("not match visitor id") {
                let service = VisitorIdService()
                let visitorId = service.visitorId
                
                service.clean()
                
                expect(VisitorIdService().visitorId).toNot(equal(visitorId))
            }
        }
    }
}
