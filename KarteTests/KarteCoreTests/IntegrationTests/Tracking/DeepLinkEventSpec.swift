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

class DeepLinkEventSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("a deep link event") {
            context("always") {
                var result: Bool!
                var event: Event!
                
                beforeEachWithMetadata { (metadata) in
                    let url = URL(string: "app://karte.com")!
                    let module = StubActionModule(self, metadata: metadata, builder: builder)
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    result = KarteApp.shared.application(UIApplication.shared, open: url)

                    event = module.wait().event(.deepLinkAppOpen)
                }
                
                it("return false") {
                    expect(result).to(beFalse())
                }

                it("event name is `deep_link_app_open`") {
                    expect(event.eventName).to(equal(.deepLinkAppOpen))
                }

                it("values.url is `url`") {
                    expect(event.values.string(forKey: "url")).to(equal("app://karte.com"))
                }
            }
        }
    }
}
