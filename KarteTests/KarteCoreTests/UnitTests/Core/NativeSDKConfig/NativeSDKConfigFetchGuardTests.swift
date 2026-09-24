//
//  Copyright 2026 PLAID, Inc.
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
@testable import KarteCore

final class NativeSDKConfigFetchGuardTests: XCTestCase {

    func testUseExecutesBlockWhenIdle() async {
        let fetchGuard = NativeSDKConfigFetchGuard()
        var executionCount = 0
        let didFirstExecute = await fetchGuard.use { executionCount += 1 }
        XCTAssertTrue(didFirstExecute)
        XCTAssertEqual(executionCount, 1)
        let didSecondExecute = await fetchGuard.use { executionCount += 1 }
        XCTAssertTrue(didSecondExecute)
        XCTAssertEqual(executionCount, 2)
    }

    func testUseDropsConcurrentCallWhileInFlight() async {
        let fetchGuard = NativeSDKConfigFetchGuard()
        let (started, startedCont) = AsyncStream<Void>.makeStream()
        let (release, releaseCont) = AsyncStream<Void>.makeStream()

        let task = Task {
            let didFirstExecute = await fetchGuard.use {
                startedCont.yield()
                for await _ in release { break } // Resumed when releaseCont.yield() is called.
            }
            XCTAssertTrue(didFirstExecute)
        }

        for await _ in started { break } // Resumed when startedCont.yield() is called.
        let didSecondExecute = await fetchGuard.use {}
        XCTAssertFalse(didSecondExecute)

        releaseCont.yield()
        await task.value
    }
}
