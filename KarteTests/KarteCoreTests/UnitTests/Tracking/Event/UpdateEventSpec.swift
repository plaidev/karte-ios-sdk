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

class UpdateEventSpec: QuickSpec {
    
    override func spec() {
        describe("a update event") {
            var service: VersionService!
            var event: Event!
            
            var versionRetriever: VersionRetrieverMock!

            afterEach {
                service.clean()
                Resolver.root = Resolver.mock
            }
            beforeEach {
                versionRetriever = VersionRetrieverMock()
                Resolver.root = Resolver.submock
                Resolver.root.register(name: "version_service.current_version_retriever") {
                    versionRetriever as VersionRetriever
                }
                
                _ = VersionService()
                
                versionRetriever.ver = "1.0.1"
                service = VersionService()
                event = Event(.update(version: service.previousVersion))
            }
            
            describe("its eventName") {
                it("is nativeAppUpdate") {
                    expect(event.eventName).to(equal(.nativeAppUpdate))
                }
            }
            
            describe("its values") {
                it("is not nil") {
                    expect(event.values).toNot(beNil())
                }
            }
            
            describe("its build values") {
                it("count is 1") {
                    expect(event.values.count).to(equal(1))
                }
                
                it("values.prev_version_name is `1.0.0`") {
                    expect(event.values.string(forKey: "prev_version_name")).to(equal("1.0.0"))
                }
            }
        }

    }
}
