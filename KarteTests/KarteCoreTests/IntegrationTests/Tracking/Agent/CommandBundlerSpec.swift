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

    init(metadata: ExampleMetadata? = nil, count: Int) {
        let metadataLabel = metadata?.example.name ?? "test"
        self.expectation = XCTestExpectation(description: "Wait for finish => \(metadataLabel)")
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

class CommandBundlerSpec: QuickSpec {
    override class func spec() {
        describe("a command bundler") {
            describe("its user bundle rule") {
                var spy: CommandBundlerSpy!

                beforeEach { (metadata: ExampleMetadata) in
                    spy = CommandBundlerSpy(metadata: metadata, count: 2)
                    
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
                }
                
                it("count is 2") {
                    expect(spy.actualCount).to(equal(2))
                }
                
                it("bundle[0] has 1 command") {
                    expect(spy.bundles[0].commands.count).to(equal(1))
                }
                
                it("bundle[1] has 2 command") {
                    expect(spy.bundles[1].commands.count).to(equal(2))
                }
            }
            
            describe("its scene bundle rule") {
                var spy: CommandBundlerSpy!

                beforeEach { (metadata: ExampleMetadata) in
                    spy = CommandBundlerSpy(metadata: metadata, count: 5)
                    
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
                }
                
                it("count is 5") {
                    expect(spy.actualCount).to(equal(5))
                }
                
                it("bundle[0] has 1 command") {
                    expect(spy.bundles[0].commands.count).to(equal(1))
                }
                
                it("bundle[1] has 2 command") {
                    expect(spy.bundles[1].commands.count).to(equal(2))
                }
                
                it("bundle[2] has 1 command") {
                    expect(spy.bundles[2].commands.count).to(equal(1))
                }
                
                it("bundle[3] has 2 command") {
                    expect(spy.bundles[3].commands.count).to(equal(2))
                }
                
                it("bundle[4] has 1 command") {
                    expect(spy.bundles[4].commands.count).to(equal(1))
                }
            }
            
            describe("its count bundle rule") {
                var spy: CommandBundlerSpy!

                beforeEach { (metadata: ExampleMetadata) in
                    spy = CommandBundlerSpy(metadata: metadata, count: 2)
                    
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
                }
                
                it("count is 2") {
                    expect(spy.actualCount).to(equal(2))
                }
                
                it("bundle[0] has 2 command") {
                    expect(spy.bundles[0].commands.count).to(equal(2))
                }
                
                it("bundle[1] has 2 command") {
                    expect(spy.bundles[1].commands.count).to(equal(2))
                }
            }
            
            describe("its time window bundle rule") {
                context("isImmediatelyBundlable is true") {
                    var spy: CommandBundlerSpy!

                    beforeEach { (metadata: ExampleMetadata) in
                        spy = CommandBundlerSpy(metadata: metadata, count: 3)

                        let scheduler = MockScheduler()
                        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(1000))
                        let bundler = CommandBundler(
                            beforeBundleRules: [],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy
                        spy.wait(timeout: 1) {
                            // 0ms: 2コマンド追加
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())

                            // 1000ms: interval経過 → 1つ目のバンドル完了
                            scheduler.advance(to: 1000)

                            // 1200ms: 3コマンド追加
                            scheduler.advance(to: 1200)
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())

                            // 2200ms: interval経過 → 2つ目のバンドル完了
                            scheduler.advance(to: 2200)

                            // 2400ms: 1コマンド追加
                            scheduler.advance(to: 2400)
                            bundler.addCommand(buildCommand())

                            // 3400ms: interval経過 → 3つ目のバンドル完了
                            scheduler.advance(to: 3400)
                        }
                    }

                    it("count is 3") {
                        expect(spy.actualCount).to(equal(3))
                    }

                    it("bundle[0] has 2 command") {
                        expect(spy.bundles[0].commands.count).to(equal(2))
                    }

                    it("bundle[1] has 3 command") {
                        expect(spy.bundles[1].commands.count).to(equal(3))
                    }
                }

                context("isImmediatelyBundlable is true to false to true") {
                    var spy: CommandBundlerSpy!

                    beforeEach { (metadata: ExampleMetadata) in
                        spy = CommandBundlerSpy(metadata: metadata, count: 2)

                        let scheduler = MockScheduler()
                        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(1000))
                        let bundler = CommandBundler(
                            beforeBundleRules: [],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy

                        spy.wait(timeout: 1) {
                            // 0ms: 2コマンド追加
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())

                            // 1000ms: interval経過 → 1つ目のバンドル完了
                            scheduler.advance(to: 1000)

                            // 1200ms: 3コマンド追加
                            scheduler.advance(to: 1200)
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())

                            // 1500ms: isImmediatelyBundlable = false
                            scheduler.advance(to: 1500)
                            timeWindowBundleRule.isImmediatelyBundlable = false

                            // 2200ms: interval経過するが、false なのでバンドルされない
                            scheduler.advance(to: 2200)

                            // 2400ms: 1コマンド追加（バンドルに追加される）
                            scheduler.advance(to: 2400)
                            bundler.addCommand(buildCommand())

                            // 4000ms: isImmediatelyBundlable = true → 2つ目のバンドル完了
                            scheduler.advance(to: 4000)
                            timeWindowBundleRule.isImmediatelyBundlable = true
                            scheduler.advance(to: 5000)
                        }
                    }

                    it("count is 2") {
                        expect(spy.actualCount).to(equal(2))
                    }

                    it("bundle[0] has 2 command") {
                        expect(spy.bundles[0].commands.count).to(equal(2))
                    }

                    it("bundle[1] has 4 command") {
                        expect(spy.bundles[1].commands.count).to(equal(4))
                    }
                }

                context("complex rules") {
                    var spy: CommandBundlerSpy!

                    beforeEach { (metadata: ExampleMetadata) in
                        spy = CommandBundlerSpy(metadata: metadata, count: 2)

                        let scheduler = MockScheduler()
                        let timeWindowBundleRule = TimeWindowBundleRule(scheduler: scheduler, interval: .milliseconds(100))
                        let bundler = CommandBundler(
                            beforeBundleRules: [SceneBundleRule()],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy

                        spy.wait(timeout: 1) {
                            // 0ms: 2コマンド追加（同じ pvId）
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())

                            // 100ms: interval経過 → 1つ目のバンドル完了
                            scheduler.advance(to: 100)

                            // 100ms〜: 3コマンド追加（別の pvId）
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))

                            // 200ms: interval経過 → 2つ目のバンドル完了
                            scheduler.advance(to: 200)
                        }
                    }

                    it("count is 2") {
                        expect(spy.actualCount).to(equal(2))
                    }

                    it("bundle[0] has 2 command") {
                        expect(spy.bundles[0].commands.count).to(equal(2))
                    }

                    it("bundle[1] has 3 command") {
                        expect(spy.bundles[1].commands.count).to(equal(3))
                    }
                }

                context("with real DispatchQueueScheduler") {
                    var spy: CommandBundlerSpy!

                    beforeEach { (metadata: ExampleMetadata) in
                        spy = CommandBundlerSpy(metadata: metadata, count: 1)

                        // 実際の DispatchQueue を使用（統合テスト）
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
                    }

                    it("bundles commands after interval") {
                        expect(spy.actualCount).to(equal(1))
                        expect(spy.bundles[0].commands.count).to(equal(2))
                    }
                }
            }
        }
    }
}
