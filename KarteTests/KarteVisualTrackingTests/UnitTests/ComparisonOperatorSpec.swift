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
@testable import KarteVisualTracking

class ComparisonOperatorSpec: QuickSpec {
    
    override class func spec() {
        describe("a comparison operator") {
            describe("its eq") {
                var op: ComparisonOperator!
                
                beforeEach {
                    op = .eq("test")
                }
                
                context("when passing `test`") {
                    it("return true") {
                        expect(op.match(value: "test")).to(beTrue())
                    }
                }
                
                context("when passing `TEST`") {
                    it("return false") {
                        expect(op.match(value: "TEST")).to(beFalse())
                    }
                }
                
                context("when passing `foo`") {
                    it("return false") {
                        expect(op.match(value: "foo")).to(beFalse())
                    }
                }
            }
            
            describe("its ne") {
                var op: ComparisonOperator!
                
                beforeEach {
                    op = .ne("test")
                }
                
                context("when passing `test`") {
                    it("return false") {
                        expect(op.match(value: "test")).to(beFalse())
                    }
                }
                
                context("when passing `TEST`") {
                    it("return true") {
                        expect(op.match(value: "TEST")).to(beTrue())
                    }
                }
                
                context("when passing `foo`") {
                    it("return true") {
                        expect(op.match(value: "foo")).to(beTrue())
                    }
                }
            }
            
            describe("its startsWith") {
                var op: ComparisonOperator!
                
                beforeEach {
                    op = .startsWith("te")
                }
                
                context("when passing `test`") {
                    it("return true") {
                        expect(op.match(value: "test")).to(beTrue())
                    }
                }
                
                context("when passing `TEST`") {
                    it("return false") {
                        expect(op.match(value: "TEST")).to(beFalse())
                    }
                }
                
                context("when passing `foo`") {
                    it("return false") {
                        expect(op.match(value: "foo")).to(beFalse())
                    }
                }
            }
            
            describe("its endsWith") {
                var op: ComparisonOperator!
                
                beforeEach {
                    op = .endsWith("st")
                }
                
                context("when passing `test`") {
                    it("return true") {
                        expect(op.match(value: "test")).to(beTrue())
                    }
                }
                
                context("when passing `TEST`") {
                    it("return false") {
                        expect(op.match(value: "TEST")).to(beFalse())
                    }
                }
                
                context("when passing `foo`") {
                    it("return false") {
                        expect(op.match(value: "foo")).to(beFalse())
                    }
                }
            }
            
            describe("its contains") {
                var op: ComparisonOperator!
                
                beforeEach {
                    op = .contains("es")
                }
                
                context("when passing `test`") {
                    it("return true") {
                        expect(op.match(value: "test")).to(beTrue())
                    }
                }
                
                context("when passing `TEST`") {
                    it("return false") {
                        expect(op.match(value: "TEST")).to(beFalse())
                    }
                }
                
                context("when passing `foo`") {
                    it("return false") {
                        expect(op.match(value: "foo")).to(beFalse())
                    }
                }
            }
        }
    }
}
