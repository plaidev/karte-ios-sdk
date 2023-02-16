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

class FindMyselfSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("a find myself") {
            context("when host is not `karte.io`") {
                var url: URL!
                
                beforeEach {
                    url = URL(string: "app://karte.com/find_myself")!
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                }
                
                it("return false") {
                    let result = KarteApp.shared.application(UIApplication.shared, open: url)
                    expect(result).to(beFalse())
                }
            }
            
            context("when path is not `/find_myself`") {
                var url: URL!
                
                beforeEach {
                    url = URL(string: "app://karte.io/foo")!
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                }
                
                it("return false") {
                    let result = KarteApp.shared.application(UIApplication.shared, open: url)
                    expect(result).to(beFalse())
                }
            }
            
            context("when valid url") {
                var result: Bool!
                var event: Event!

                beforeEachWithMetadata { (metadata) in
                    let url = URL(string: "app://karte.io/find_myself?k=v")!
                    let module = StubActionModule(self, metadata: metadata, builder: builder)

                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    result = KarteApp.shared.application(UIApplication.shared, open: url)

                    event = module.wait().event(.nativeFindMyself)
                }

                it("return true") {
                    expect(result).to(beTrue())
                }

                it("event name is `native_find_myself`") {
                    expect(event.eventName).to(equal(.nativeFindMyself))
                }

                it("values.k is `v`") {
                    expect(event.values.string(forKey: "k")).to(equal("v"))
                }
            }
        }
    }
}
