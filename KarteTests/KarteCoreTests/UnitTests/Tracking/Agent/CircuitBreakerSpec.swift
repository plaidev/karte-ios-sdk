//
//  Copyright 2021 PLAID, Inc.
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

class CircuitBreakerSpec: QuickSpec {
    
    override class func spec() {
        describe("a circuit breaker") {
            var circuitBreaker: CircuitBreaker!
            var todaySupplier: TodaySupplierMock!
            
            beforeEach {
                todaySupplier = TodaySupplierMock(DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 0))
                circuitBreaker = CircuitBreaker(threshold: 3, recoverAfterSec: 20, todaySupplier: todaySupplier)
            }
            
            context("the number of failures that do not exceed the threshold") {
                it("is acceptable") {
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                }
            }
            
            context("failures beyond the threshold") {
                it("are limited") {
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beFalse())
                }
            }
            
            context("resetting") {
                it("removes the restriction") {
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beFalse())

                    circuitBreaker.reset()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beFalse())
                }
            }
            context("after a certain period of time without resetting") {
                it("removes the restriction") {
                    todaySupplier.todayDateComponents = DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 0)
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beFalse())
                    
                    
                    todaySupplier.todayDateComponents = DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 21)
                    expect(circuitBreaker.canRequest).to(beTrue())
                    
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beTrue())
                    circuitBreaker.countFailure()
                    expect(circuitBreaker.canRequest).to(beFalse())
                    
                    todaySupplier.todayDateComponents = DateComponents(year: 2021, month: 10, day: 1, hour: 0, minute: 0, second: 42)
                    expect(circuitBreaker.canRequest).to(beTrue())
                }
            }
        }
    }
}
