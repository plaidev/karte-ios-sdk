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
import KarteUtilities
@testable import KarteCore

class TrackSpec: QuickSpec {
    
    override func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!
        
        let num = 100
        let str = "foo"
        let bool = true
        let date = Date()
        let dictValue = "value"
        let dict: [String: JSONConvertible] = ["key": dictValue]
        let arrValue1 = "value1"
        let arrValue2 = "value2"
        let arr: [JSONConvertible] = [arrValue1, arrValue2]
        let values: [String: JSONConvertible] = [
            "num": num,
            "str": str,
            "bool": bool,
            "date": date,
            "arr": arr,
            "dict": dict
        ]

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
        
        describe("a tracker") {
            describe("its track") {
                var event: Event!
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: EventName("test")) { (_, _, e) in
                        event = e
                    }
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                    let event = Event(eventName: EventName("test"), values: values)
                    Tracker.track(event: event)
                    
                    module.wait()
                }
                
                it("event name is `test`") {
                    expect(event.eventName).to(equal(EventName("test")))
                }
                
                it("values.num is 100") {
                    expect(event.values.integer(forKey: "num")).to(equal(num))
                }
                
                it("values.str is `foo`") {
                    expect(event.values.string(forKey: "str")).to(equal(str))
                }
                
                it("values.bool is true") {
                    expect(event.values.bool(forKey: "bool")).to(beTrue())
                }
                
                it("values.date is now") {
                    expect(event.values.date(forKey: "date")).to(beCloseTo(date, within: 0.0001))
                }
                
                it("values.arr.0 is `value1`") {
                    expect(event.values.string(forKeyPath: "arr.0")).to(equal(arrValue1))
                }
                
                it("values.arr.1 is `value2`") {
                    expect(event.values.string(forKeyPath: "arr.1")).to(equal(arrValue2))
                }
                
                it("values.dict.key is `value`") {
                    expect(event.values.string(forKeyPath: "dict.key")).to(equal(dictValue))
                }
                
                it("values._local_event_date is not nil") {
                    expect(event.values.date(forKey: field(.localEventDate))).toNot(beNil())
                }
                
                it("values._retry is nil") {
                    expect(event.values.bool(forKey: field(.retry))).to(beNil())
                }
            }
            
            describe("its track compatible") {
                var event: Event!
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: EventName("test")) { (_, _, e) in
                        event = e
                    }
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                    Tracker.track("test", values: values)
                    
                    module.wait()
                }
                
                it("event name is `test`") {
                    expect(event.eventName).to(equal(EventName("test")))
                }
                
                it("values.num is 100") {
                    expect(event.values.integer(forKey: "num")).to(equal(num))
                }
                
                it("values.str is `foo`") {
                    expect(event.values.string(forKey: "str")).to(equal(str))
                }
                
                it("values.bool is true") {
                    expect(event.values.bool(forKey: "bool")).to(beTrue())
                }
                
                it("values.date is now") {
                    expect(event.values.date(forKey: "date")).to(beCloseTo(date, within: 0.0001))
                }
                
                it("values.arr.0 is `value1`") {
                    expect(event.values.string(forKeyPath: "arr.0")).to(equal(arrValue1))
                }
                
                it("values.arr.1 is `value2`") {
                    expect(event.values.string(forKeyPath: "arr.1")).to(equal(arrValue2))
                }
                
                it("values.dict.key is `value`") {
                    expect(event.values.string(forKeyPath: "dict.key")).to(equal(dictValue))
                }
                
                it("values._local_event_date is not nil") {
                    expect(event.values.date(forKey: field(.localEventDate))).toNot(beNil())
                }
                
                it("values._retry is nil") {
                    expect(event.values.bool(forKey: field(.retry))).to(beNil())
                }
            }
        }
    }
}
