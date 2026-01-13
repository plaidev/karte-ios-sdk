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

class VersionServiceSpec: QuickSpec {
    
    override class func spec() {
        var versionRetriever: VersionRetrieverMock!
        
        beforeEach {
            versionRetriever = VersionRetrieverMock()
            
            Resolver.root = Resolver.submock
            Resolver.root.register(name: "version_service.current_version_retriever") {
                versionRetriever as VersionRetriever
            }
        }
        
        afterEach {
            VersionService().clean()
            Resolver.root = Resolver.mock
        }
        
        describe("its state") {
            context("when launch after installation") {
                it("state is install") {
                    let service = VersionService()
                    expect(service.installationStatus).to(equal(.install))
                }
            }
            
            context("when launch after update") {
                beforeEach {
                    _ = VersionService()
                }
                
                it("state is update") {
                    versionRetriever.ver = "1.0.1"
                    
                    let service = VersionService()
                    expect(service.installationStatus).to(equal(.update))
                }
            }
            
            context("when normal launch") {
                beforeEach {
                    versionRetriever.ver = "1.0.1"
                    _ = VersionService()
                }

                it("state is unknown") {
                    let service = VersionService()
                    expect(service.installationStatus).to(equal(.unknown))
                }
            }
        }
        
        describe("its delete") {
            it("previous version is nil") {
                versionRetriever.ver = "9.9.9"
                let service = VersionService()
                service.clean()

                expect(VersionService().previousVersion).to(beNil())
            }
        }
    }
}
