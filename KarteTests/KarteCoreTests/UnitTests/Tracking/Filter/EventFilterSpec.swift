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

class EventFilterSpec: QuickSpec {
    
    override func spec() {
        describe("a empty event name filter rule") {
            var filter: EventFilter!
            
            beforeEach {
                filter = EventFilter.Builder().add(EmptyEventNameFilterRule()).build()
            }
            
            context("when event name is empty") {
                it("throw error") {
                    let event = Event(eventName: EventName(""))
                    expect { try filter.filter(event) }.to(throwError())
                }
            }
            
            context("when event name is nativeAppOpen") {
                it("not throw error") {
                    expect { try filter.filter(Event(.open)) }.toNot(throwError())
                }
            }
        }
        
        describe("a non ascii event name filter rule") {
            var filter: EventFilter!
            
            beforeEach {
                filter = EventFilter.Builder().add(NonAsciiEventNameFilterRule()).build()
            }
            
            context("when event name contains non ascii character") {
                it("not throw error") {
                    let event = Event(eventName: EventName("イベント"))
                    expect { try filter.filter(event) }.toNot(throwError())
                }
            }
            
            context("when event name not contains non ascii character") {
                it("not throw error") {
                    let event = Event(eventName: EventName("event"))
                    expect { try filter.filter(event) }.toNot(throwError())
                }
            }
        }
        
        describe("a default event filter rule") {
            var filter: EventFilter!
            
            beforeEach {
                filter = EventFilter.Builder().add(InitializationEventFilterRule()).build()
            }
            
            context("when event is initialization event") {
                it("throw error") {
                    expect { try filter.filter(Event(.open)) }.to(throwError())
                }
            }
            
            context("when event is not initialization event") {
                it("not throw error") {
                    let event = Event(eventName: EventName("event"))
                    expect { try filter.filter(event) }.toNot(throwError())
                }
            }
        }
    }
}
