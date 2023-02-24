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
@testable import KarteCore

class TrackEventRejectionFilterSpec: QuickSpec {
    override func spec() {        
        describe("check track event filter") {
            var filter: TrackEventRejectionFilter!
            
            beforeEach {
                filter = TrackEventRejectionFilter()
                filter.add(rule: TestRule(libraryName: "m1", eventName: EventName("e1"), value: "v1"))
            }
            
            context("included in the test") {
                it("the result is false when the condition is matched") {
                    let event = Event(eventName: EventName("e1"), values: ["f1": "v1"], libraryName: "m1")
                    expect(filter.reject(event: event)).to(beFalse())
                }
                it("the result is true when the condition is not matched") {
                    let event = Event(eventName: EventName("e1"), values: ["f1": "v2"], libraryName: "m1")
                    expect(filter.reject(event: event)).to(beTrue())
                }
            }
            
            context("not included in the test") {
                it("the result is false when the module name is not matched") {
                    let event = Event(eventName: EventName("e1"), values: ["f1": "v1"], libraryName: "m2")
                    expect(filter.reject(event: event)).to(beFalse())
                }
                
                it("the result is false when the event name is not matched") {
                    let event = Event(eventName: EventName("e2"), values: ["f1": "v1"], libraryName: "m1")
                    expect(filter.reject(event: event)).to(beFalse())
                }
            }
        }
    }
}

extension TrackEventRejectionFilterSpec {
    struct TestRule: TrackEventRejectionFilterRule {
        var libraryName: String
        var eventName: EventName
        var value: String
        
        init(libraryName: String, eventName: EventName, value: String) {
            self.libraryName = libraryName
            self.eventName = eventName
            self.value = value
        }
        
        func reject(event: Event) -> Bool {
            return event.values.string(forKeyPath: "f1") != value
        }
    }
}
