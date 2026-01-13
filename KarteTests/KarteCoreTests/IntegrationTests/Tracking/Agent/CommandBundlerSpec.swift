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

class CommandBundlerSpy {
    private var testCase: XCTestCase
    private var expectation: XCTestExpectation

    var queue = DispatchQueue(
        label: "io.karte.spec",
        qos: .utility
    )
    var estimatedCount = 0
    var actualCount = 0
    var bundles = [CommandBundle]()


    init(spec: Any, metadata: ExampleMetadata? = nil, count: Int) {
        let metadataLabel = metadata?.example.name ?? "test"

        // Accept both QuickSpec and QuickSpec.Type
        if let testCase = spec as? XCTestCase {
            self.testCase = testCase
        } else if let _ = spec as? XCTestCase.Type {
            // For class methods, create a minimal XCTestCase
            self.testCase = XCTestCase()
        } else {
            fatalError("spec must be XCTestCase or XCTestCase.Type")
        }

        self.expectation = self.testCase.expectation(description: "Wait for finish => \(metadataLabel)")
        self.estimatedCount = count
    }

    func wait(timeout: TimeInterval = 4, execute: @escaping () -> Void) {
        queue.async(execute: execute)

        expectation.assertForOverFulfill = false
        expectation.expectedFulfillmentCount = estimatedCount

        testCase.wait(for: [expectation], timeout: timeout)
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
            beforeEach {
                Thread.sleep(forTimeInterval: 2)
            }
            
            describe("its user bundle rule") {
                var spy: CommandBundlerSpy!

                beforeEach { (metadata: ExampleMetadata) in
                    spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 2)
                    
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
                    spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 5)
                    
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
                    spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 2)
                    
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
                        spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 3)
                        
                        let timeWindowBundleRule = TimeWindowBundleRule(queue: spy.queue, interval: .milliseconds(1000))
                        let bundler = CommandBundler(
                            beforeBundleRules: [],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy
                        spy.wait(timeout: 10) {
                            spy.queue.async {
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(1200)) {
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(2400)) {
                                bundler.addCommand(buildCommand())
                            }
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
                        spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 2)
                        
                        let timeWindowBundleRule = TimeWindowBundleRule(queue: spy.queue, interval: .milliseconds(1000))
                        let bundler = CommandBundler(
                            beforeBundleRules: [],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy

                        spy.wait(timeout: 5) {
                            spy.queue.async {
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(1200)) {
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                                bundler.addCommand(buildCommand())
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                timeWindowBundleRule.isImmediatelyBundlable = false
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(2400)) {
                                bundler.addCommand(buildCommand())
                            }
                            spy.queue.asyncAfter(deadline: .now() + .milliseconds(4000)) {
                                timeWindowBundleRule.isImmediatelyBundlable = true
                            }
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
                        spy = CommandBundlerSpy(spec: self, metadata: metadata, count: 2)
                        
                        let timeWindowBundleRule = TimeWindowBundleRule(queue: spy.queue, interval: .milliseconds(100))
                        let bundler = CommandBundler(
                            beforeBundleRules: [SceneBundleRule()],
                            afterBundleRules: [],
                            asyncBundleRules: [timeWindowBundleRule]
                        )
                        bundler.delegate = spy
                        
                        spy.wait {
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand())
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
                            bundler.addCommand(buildCommand(pvId: PvId("dummy-pv-id-1")))
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
            }
        }
    }
}
