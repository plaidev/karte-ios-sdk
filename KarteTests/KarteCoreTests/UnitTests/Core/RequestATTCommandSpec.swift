//
//  Copyright 2024 PLAID, Inc.
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

class RequestATTCommandSpec: QuickSpec {
    override class func spec() {
        describe("its run") {
            context("when invalid value passed") {
                let examples = [
                    "test:",
                    "krt:",
                    "krt://request-att",
                    "aaa-karte-sdk://request-att",
                    "krt-hSZM://request-att",
                    "krt-hSZMcVyjwg6Y7pdYMa4YPqmyQ77EpALw://request-review",
                ]
                examples.forEach { (input) in
                    context("\(input)") {
                        it("returns false") {
                            let c = RequestATTCommand()
                            let u = URL(string: input)!
                            expect(c.run(url: u)).to(beFalse())
                        }
                    }
                }
            }
            
            context("when valid value passed") {
                let examples = [
                    "krt-hSZMcVyjwg6Y7pdYMa4YPqmyQ77EpALw://request-att",
                    "krt-HRTwj9QEZGJrTaTkADrtdxFTyuXUJVMh://request-att"
                ]
                examples.forEach { (input) in
                    context("\(input)") {
                        it("returns true") {
                            let c = RequestATTCommand()
                            let u = URL(string: input)!
                            expect(c.run(url: u)).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}
