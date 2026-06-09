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

import XCTest
@testable import KarteUtilities
@testable import KarteCore

/// テスト用の仮想時間スケジューラー
class MockScheduler: AsyncScheduler {
    private var currentTimeMs: Int = 0
    private var pendingTasks: [(deadlineMs: Int, execute: () -> Void)] = []

    func scheduleAfter(interval: DispatchTimeInterval, execute: @escaping () -> Void) {
        let deadlineMs = currentTimeMs + interval.toMilliseconds()
        pendingTasks.append((deadlineMs: deadlineMs, execute: execute))
    }

    /// 指定した時間だけ仮想時間を進め、期限が来たタスクを実行
    func advance(by interval: DispatchTimeInterval) {
        currentTimeMs += interval.toMilliseconds()
        runDueTasks()
    }

    /// 指定した時間まで仮想時間を進め、期限が来たタスクを実行
    func advance(to timeMs: Int) {
        currentTimeMs = timeMs
        runDueTasks()
    }

    private func runDueTasks() {
        // 期限が来たタスクを実行（実行中に新しいタスクが追加される可能性あり）
        while let index = pendingTasks.firstIndex(where: { $0.deadlineMs <= currentTimeMs }) {
            let task = pendingTasks.remove(at: index)
            task.execute()
        }
    }
}

extension DispatchTimeInterval {
    func toMilliseconds() -> Int {
        switch self {
        case .seconds(let s): return s * 1000
        case .milliseconds(let ms): return ms
        case .microseconds(let us): return us / 1000
        case .nanoseconds(let ns): return ns / 1_000_000
        case .never: return Int.max
        @unknown default: return 0
        }
    }
}

class CommandBundlerSpy {
    private var expectation: XCTestExpectation

    var queue = DispatchQueue(
        label: "io.karte.spec",
        qos: .utility
    )
    var estimatedCount = 0
    var actualCount = 0
    var bundles = [CommandBundle]()

    init(count: Int, testName: String = #function) {
        self.expectation = XCTestExpectation(description: "Wait for finish => \(testName)")
        self.estimatedCount = count
    }

    func wait(timeout: TimeInterval = 4, execute: @escaping () -> Void) {
        queue.async(execute: execute)

        expectation.assertForOverFulfill = false
        expectation.expectedFulfillmentCount = estimatedCount

        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        if result != .completed {
            XCTFail("Expectation not fulfilled: \(result)")
        }
    }
}

extension CommandBundlerSpy: CommandBundlerDelegate {
    func commandBundler(_ bundler: CommandBundler, didFinishBundle bundle: CommandBundle) {
        actualCount += 1
        bundles.append(bundle)
        expectation.fulfill()
    }
}

class CommandBundlerSpec: XCTestCase {
    func testUserBundlerRule() {
        let spy = CommandBundlerSpy(count: 2)

        let bundler = CommandBundler(
            beforeBundleRules: [UserBundleRule()],
            afterBundleRules: [],
            asyncBundleRules: []
        )
        bundler.delegate = spy

        spy.wait {
            bundler.addCommand(buildCommand(visitorId: "dummy-vis-a"))
            bundler.addCommand(buildCommand(visitorId: "dummy-vis-b"))
            bundler.addCommand(buildCommand(visitorId: "dummy-vis-b"))
            bundler.addCommand(buildCommand(visitorId: "dummy-vis-c"))
        }

        XCTAssertEqual(spy.actualCount, 2, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 1, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 2, "bundle[1].commands.count")
    }

    func testSceneBundlerRule() {
        let spy = CommandBundlerSpy(count: 5)

        let bundler = CommandBundler(
            beforeBundleRules: [SceneBundleRule()],
            afterBundleRules: [],
            asyncBundleRules: []
        )
        bundler.delegate = spy

        spy.wait {
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1"), sceneId: SceneId("dummy-scene-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-2"), sceneId: SceneId("dummy-scene-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-2"), sceneId: SceneId("dummy-scene-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-3"), sceneId: SceneId("dummy-scene-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-3"), sceneId: SceneId("dummy-scene-id-2")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-3"), sceneId: SceneId("dummy-scene-id-2")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-4"), sceneId: SceneId("dummy-scene-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-5"), sceneId: SceneId("dummy-scene-id-1")))
        }

        XCTAssertEqual(spy.actualCount, 5, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 1, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 2, "bundle[1].commands.count")
        XCTAssertEqual(spy.bundles[2].commands.count, 1, "bundle[2].commands.count")
        XCTAssertEqual(spy.bundles[3].commands.count, 2, "bundle[3].commands.count")
        XCTAssertEqual(spy.bundles[4].commands.count, 1, "bundle[4].commands.count")
    }

    func testCommandCountBundlerRule() {
        let spy = CommandBundlerSpy(count: 2)

        let bundler = CommandBundler(
            beforeBundleRules: [],
            afterBundleRules: [CommandCountBundleRule(count: 2)],
            asyncBundleRules: []
        )
        bundler.delegate = spy

        spy.wait {
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
        }

        XCTAssertEqual(spy.actualCount, 2, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 2, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 2, "bundle[1].commands.count")
    }

    func testTimeWindowBundlerRuleIsImmediatelyBundlable() {
        let spy = CommandBundlerSpy(count: 3)

        let scheduler = MockScheduler()
        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(1000))
        let bundler = CommandBundler(
            beforeBundleRules: [],
            afterBundleRules: [],
            asyncBundleRules: [timeWindowBundleRule]
        )
        bundler.delegate = spy
        spy.wait(timeout: 1) {
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 1000)

            scheduler.advance(to: 1200)
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 2200)

            scheduler.advance(to: 2400)
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 3400)
        }

        XCTAssertEqual(spy.actualCount, 3, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 2, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 3, "bundle[1].commands.count")
        XCTAssertEqual(spy.bundles[2].commands.count, 1, "bundle[2].commands.count")
    }

    func testTimeWindowBundlerRuleIsImmediatelyBundlableTransition() {
        let spy = CommandBundlerSpy(count: 2)

        let scheduler = MockScheduler()
        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(1000))
        let bundler = CommandBundler(
            beforeBundleRules: [],
            afterBundleRules: [],
            asyncBundleRules: [timeWindowBundleRule]
        )
        bundler.delegate = spy

        spy.wait(timeout: 1) {
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 1000)

            scheduler.advance(to: 1200)
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 1500)
            timeWindowBundleRule.isImmediatelyBundlable = false

            scheduler.advance(to: 2200)

            scheduler.advance(to: 2400)
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 4000)
            timeWindowBundleRule.isImmediatelyBundlable = true
            scheduler.advance(to: 5000)
        }

        XCTAssertEqual(spy.actualCount, 2, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 2, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 4, "bundle[1].commands.count")
    }

    func testTimeWindowBundlerRuleComplexRules() {
        let spy = CommandBundlerSpy(count: 2)

        let scheduler = MockScheduler()
        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(100))
        let bundler = CommandBundler(
            beforeBundleRules: [SceneBundleRule()],
            afterBundleRules: [],
            asyncBundleRules: [timeWindowBundleRule]
        )
        bundler.delegate = spy

        spy.wait(timeout: 1) {
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())

            scheduler.advance(to: 100)

            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))

            scheduler.advance(to: 200)
        }

        XCTAssertEqual(spy.actualCount, 2, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 2, "bundle[0].commands.count")
        XCTAssertEqual(spy.bundles[1].commands.count, 3, "bundle[1].commands.count")
    }

    func testTimeWindowBundlerRuleWithRealDispatchQueueScheduler() {
        let spy = CommandBundlerSpy(count: 1)

        let timeWindowBundleRule = TimeWindowBundleRule(queue: spy.queue, interval: .milliseconds(50))
        let bundler = CommandBundler(
            beforeBundleRules: [],
            afterBundleRules: [],
            asyncBundleRules: [timeWindowBundleRule]
        )
        bundler.delegate = spy
        spy.wait(timeout: 3) {
            bundler.addCommand(buildCommand())
            bundler.addCommand(buildCommand())
        }

        XCTAssertEqual(spy.actualCount, 1, "actualCount")
        XCTAssertEqual(spy.bundles[0].commands.count, 2, "bundle[0].commands.count")
    }
}
