//
//  Copyright 2023 PLAID, Inc.
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
import KarteUtilities
@testable import KarteCore
@testable import KarteVariables

class TrackVariablesSpec: QuickSpec {
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!

        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = { (request) -> Response in
                let response = TrackResponse(success: 1, status: 200, response: .emptyResponse, error: nil)
                let data = try! createJSONEncoder().encode(response)
                return jsonData(data)(request)
            }
        }

        describe("track message_open") {
            var event: Event!
            beforeEachWithMetadata { (metadata) in
                let module = StubActionModule(self, metadata: metadata, builder: builder)
                
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                let variable = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: "t1", eventHash: "h1")
                Tracker.trackOpen(variables: [variable], values: ["foo": "bar"])
                
                event = module.wait().event(.messageOpen)
            }
            
            it("event name is `message_open`") {
                expect(event.eventName).to(equal(.messageOpen))
            }

            it("values.message.campaign_id is `c1`") {
                expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("c1"))
            }

            it("values.message.shorten_id is `s1`") {
                expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("s1"))
            }

            it("values.message.response_id is `t1_s1`") {
                expect(event.values.string(forKeyPath: "message.response_id")).to(equal("t1_s1"))
            }

            it("values.message.response_timestamp is `t1`") {
                expect(event.values.string(forKeyPath: "message.response_timestamp")).to(equal("t1"))
            }

            it("values.message.trigger.event_hashes is `h1`") {
                expect(event.values.string(forKeyPath: "message.trigger.event_hashes")).to(equal("h1"))
            }

            it("values.no_action is false") {
                expect(event.values.bool(forKeyPath: "no_action")).to(beNil())
            }
            
            it("values.foo is `bar`") {
                expect(event.values.string(forKeyPath: "foo")).to(equal("bar"))
            }
        }
        
        
        describe("track message_click") {
            var event: Event!
            beforeEachWithMetadata { (metadata) in
                let module = StubActionModule(self, metadata: metadata, builder: builder)
                
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                let variable = Variable(name: "foo", campaignId: "c1", shortenId: "s1", value: "bar", timestamp: "t1", eventHash: "h1")
                Tracker.trackClick(variables: [variable], values: ["foo": "bar"])
                
                event = module.wait().event(.messageClick)
            }
            
            it("event name is `message_click`") {
                expect(event.eventName).to(equal(.messageClick))
            }

            it("values.message.campaign_id is `c1`") {
                expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("c1"))
            }

            it("values.message.shorten_id is `s1`") {
                expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("s1"))
            }

            it("values.message.response_id is `t1_s1`") {
                expect(event.values.string(forKeyPath: "message.response_id")).to(equal("t1_s1"))
            }

            it("values.message.response_timestamp is `t1`") {
                expect(event.values.string(forKeyPath: "message.response_timestamp")).to(equal("t1"))
            }

            it("values.message.trigger.event_hashes is `h1`") {
                expect(event.values.string(forKeyPath: "message.trigger.event_hashes")).to(equal("h1"))
            }

            it("values.no_action is false") {
                expect(event.values.bool(forKeyPath: "no_action")).to(beNil())
            }
            
            it("values.foo is `bar`") {
                expect(event.values.string(forKeyPath: "foo")).to(equal("bar"))
            }
        }
    }
}
