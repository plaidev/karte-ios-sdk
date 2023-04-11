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

import XCTest
@testable import KarteUtilities

class SafeSwizzlerTests: XCTestCase {
    func testSwizzle() {
        let proxy1 = CounterProxy1()
        let proxy2 = CounterProxy2()

        proxy1.swizzle()
        
        let counter = Counter()
        counter.increment()
        XCTAssertEqual(counter.count, 2)
        
        counter.decrement()
        XCTAssertEqual(counter.count, 1)
        
        proxy2.swizzle()
        
        counter.increment()
        XCTAssertEqual(counter.count, 5)
        
        counter.decrement()
        XCTAssertEqual(counter.count, 2)
        
        proxy2.unswizzle()
        
        counter.increment()
        XCTAssertEqual(counter.count, 4)
        
        counter.decrement()
        XCTAssertEqual(counter.count, 3)
        
        proxy1.unswizzle()
        
        counter.increment()
        XCTAssertEqual(counter.count, 4)

        counter.decrement()
        XCTAssertEqual(counter.count, 3)
    }
}

extension SafeSwizzlerTests {
    class Counter: NSObject {
        var count = 0

        @objc dynamic func increment() {
            count += 1
        }

        @objc dynamic func decrement() {
            count -= 1
        }
    }

    class CounterProxy1: NSObject {
        let scope = SafeSwizzler.scope { builder in
            builder.add(CounterProxy1.self)
        }
        
        func swizzle() {
            let block: @convention(block) (Any) -> Void = increment
            scope.swizzle(cls: Counter.self, name: #selector(Counter.increment), imp: imp_implementationWithBlock(block))
        }
        
        func unswizzle() {
            scope.unswizzle(cls: Counter.self, name: #selector(Counter.increment))
        }
        
        func increment(receiver: Any) {
            guard let receiver = receiver as? Counter else {
                return
            }
            receiver.count += 1
            
            let imp = scope.originalImplementation(cls: Counter.self, name: #selector(Counter.increment))
            let f = unsafeBitCast(imp, to: (@convention(c) (Any, Selector) -> Void).self)
            f(receiver, #selector(Counter.increment))
        }
    }

    class CounterProxy2: NSObject {
        let scope = SafeSwizzler.scope { builder in
            builder.add(CounterProxy2.self)
        }
        
        func swizzle() {
            let incrementBlock: @convention(block) (Any) -> Void = increment
            scope.swizzle(cls: Counter.self, name: #selector(Counter.increment), imp: imp_implementationWithBlock(incrementBlock))
            
            let decrementBlock: @convention(block) (Any) -> Void = decrement
            scope.swizzle(cls: Counter.self, name: #selector(Counter.decrement), imp: imp_implementationWithBlock(decrementBlock))
        }
        
        func unswizzle() {
            scope.unswizzle()
        }

        func increment(receiver: Any) {
            guard let receiver = receiver as? Counter else {
                return
            }
            receiver.count += 2
            
            let imp = scope.originalImplementation(cls: Counter.self, name: #selector(Counter.increment))
            let f = unsafeBitCast(imp, to: (@convention(c) (Any, Selector) -> Void).self)
            f(receiver, #selector(Counter.increment))
        }
        
        func decrement(receiver: Any) {
            guard let receiver = receiver as? Counter else {
                return
            }
            receiver.count -= 2
            
            let imp = scope.originalImplementation(cls: Counter.self, name: #selector(Counter.decrement))
            let f = unsafeBitCast(imp, to: (@convention(c) (Any, Selector) -> Void).self)
            f(receiver, #selector(Counter.decrement))
        }
    }
}
