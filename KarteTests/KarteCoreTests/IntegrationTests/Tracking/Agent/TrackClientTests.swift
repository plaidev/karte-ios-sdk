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
import KarteUtilities
@testable import KarteCore

class Counter: NSObject {
    @objc dynamic var count:Int = 0
    
    static func += ( left: inout Counter, right: Int) {
        left.count += right
    }
}

class CircuitBreakerMock : CircuitBreaker {
    var counter = Counter()
    var count:Int {
        counter.count
    }
    var disable = false
    override func countFailure() {
        super.countFailure()
        counter += 1
    }
    
    override var canRequest: Bool {
        if disable {return true}
        return super.canRequest
    }
    
    override func reset() {
        counter.count = 0
        super.reset()
    }
}

class TrackClientTests: XCTestCase {
    var session: TrackClientSessionMock!
    var reachabilityService: ReachabilityServiceMock!
    var circuitBreaker: CircuitBreakerMock!
    var maxRetryCount = 3
    var exp: XCTestExpectation!
    var stub: Stub!
    
    override func setUpWithError() throws {
        Resolver.registerMockServices()
        
        let session = TrackClientSessionMock()
        self.session = session
        
        let reachabilityService = ReachabilityServiceMock()
        self.reachabilityService = reachabilityService
        
        let circuitBreaker = CircuitBreakerMock()
        self.circuitBreaker = circuitBreaker
        
        Resolver.root = Resolver.submock
        Resolver.root.register {
            session as any TrackClientSession
        }
        Resolver.root.register { (_, _) -> any ReachabilityService in
            reachabilityService as any ReachabilityService
        }
        Resolver.root.register { ExponentialBackoff(interval: 0, randomFactor: 0, multiplier: 0, maxCount: self.maxRetryCount) }
        Resolver.root.register { circuitBreaker as CircuitBreaker }
        
        KarteApp.shared.teardown()
    }

    override func tearDownWithError() throws {
        Resolver.root = Resolver.mock
        KarteApp.shared.teardown()
    }
    
    private func waitTrackingAgentHasNoCommandsNotification(notified: (() -> ())? = nil) {
        self.exp = expectation(forNotification: TrackingAgent.trackingAgentHasNoCommandsNotification, object: nil) { [weak self] (_) -> Bool in
            guard let self = self else {
                return true
            }
            notified?()
            self.exp.fulfill()
            return true
        }
        
        wait(for: [exp], timeout: 20)
    }

    private final class CallbackQueuePoll {
        let lock = NSLock()
        var stop = false
    }

    private func waitOnCallbackQueue(
        timeout: TimeInterval = 10,
        file: StaticString = #filePath,
        line: UInt = #line,
        until ready: @escaping () -> Bool,
        then action: (() -> Void)? = nil
    ) {
        let finished = expectation(description: "callbackQueue")
        finished.assertForOverFulfill = false
        let poll = CallbackQueuePoll()

        func check() {
            poll.lock.lock()
            let shouldStop = poll.stop
            poll.lock.unlock()
            if shouldStop {
                return
            }
            if ready() {
                finished.fulfill()
                return
            }
            TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .milliseconds(20), execute: check)
        }

        TrackClient.shared.callbackQueue.async(execute: check)
        let result = XCTWaiter.wait(for: [finished], timeout: timeout)
        poll.lock.lock()
        poll.stop = true
        poll.lock.unlock()
        if result != .completed {
            continueAfterFailure = false
            XCTFail("timed out waiting on callbackQueue", file: file, line: line)
            return
        }
        if let action {
            TrackClient.shared.callbackQueue.sync(execute: action)
        }
    }

    func testTeardown() throws {
        let configuration = Configuration { configuration in
            // setup時に自動送信される初期イベントを無効化する
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        // teardownで、isReachableがtrueからfalseに戻ることを検証するためのセットアップ
        reachabilityService.notify(true)
        waitOnCallbackQueue(until: {
            TrackClient.shared.isReachable
        })

        // isSending、tasks、stateを送信中の状態にし、teardownで初期化されることを検証するためのセットアップ
        // session.send は clientQueue に積まれる。次のテストがモックを差し替える前に、このセッションが受け取るまで待つ。
        session.isAutoFlush = false
        let request = try XCTUnwrap(
            TrackRequest(app: KarteApp.shared, commands: [buildCommand()])
        )
        TrackClient.shared.enqueue(request: request) { _ in }
        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
        })

        XCTAssertNotNil(TrackClient.shared.reachability)
        XCTAssertTrue(TrackClient.shared.isReachable)
        XCTAssertTrue(TrackClient.shared.isSending)
        XCTAssertNotEqual(TrackClient.shared.callbackQueue.label, DispatchQueue.main.label)
        XCTAssertEqual(TrackClient.shared.state, .running)
        XCTAssertFalse(TrackClient.shared.tasks.isEmpty)
        XCTAssertFalse(TrackClient.shared.observers.isEmpty)
        XCTAssertEqual(reachabilityService.startNotifierCallCount, 1)
        XCTAssertEqual(reachabilityService.stopNotifierCallCount, 0)

        KarteApp.shared.teardown()

        XCTAssertNil(TrackClient.shared.reachability)
        XCTAssertFalse(TrackClient.shared.isReachable)
        XCTAssertFalse(TrackClient.shared.isSending)
        XCTAssertEqual(TrackClient.shared.callbackQueue.label, DispatchQueue.main.label)
        XCTAssertEqual(TrackClient.shared.state, .waiting)
        XCTAssertTrue(TrackClient.shared.tasks.isEmpty)
        XCTAssertTrue(TrackClient.shared.observers.isEmpty)
        XCTAssertEqual(reachabilityService.stopNotifierCallCount, 1)
    }

    func testTrackClient() throws {
        self.stub = stub(uri("/v0/native/track"), StubBuilder(test: self, resource: .empty).build())
        
        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        session.isAutoFlush = false
        reachabilityService.notify(true)
        
        let noCommandsNotificationExpectation = expectation(forNotification: TrackingAgent.trackingAgentHasNoCommandsNotification, object: nil)

        Tracker.view("test1")
        Tracker.view("test2")
        Tracker.view("test3")
        Tracker.view("test4")

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
                && TrackClient.shared.tasks.count == 3
                && TrackClient.shared.state == .running
        }, then: {
            self.session.flush()
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
                && TrackClient.shared.tasks.count == 2
                && TrackClient.shared.state == .running
        }, then: {
            self.reachabilityService.notify(false)
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
                && TrackClient.shared.tasks.count == 2
                && TrackClient.shared.state == .running
                && !TrackClient.shared.isReachable
        }, then: {
            self.session.flush()
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 0
                && TrackClient.shared.tasks.count == 1
                && TrackClient.shared.state == .running
        }, then: {
            self.reachabilityService.notify(true)
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
                && TrackClient.shared.tasks.count == 1
                && TrackClient.shared.state == .running
                && TrackClient.shared.isReachable
        }, then: {
            self.session.flush()
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 1
                && TrackClient.shared.tasks.count == 1
                && TrackClient.shared.state == .running
        }, then: {
            self.session.flush()
        })

        waitOnCallbackQueue(until: {
            self.session.tasks.count == 0
                && TrackClient.shared.tasks.count == 0
                && TrackClient.shared.state == .waiting
        })

        wait(for: [noCommandsNotificationExpectation], timeout: 5)
        self.removeStub(self.stub)
    }
    
    func testTrackClientWithoutRetry() throws {
        let successResponse = StubBuilder(test: self, resource: .empty).build()
        let badRequestResponse = StubBuilder(test: self, resource: .failure_invalid_request).build(status: 400)
        
        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        session.isAutoFlush = true
        reachabilityService.notify(true)
        
        // status: 200 の時はリトライしない(失敗にカウントしない)
        self.stub = stub(uri("/v0/native/track"), successResponse)
        Tracker.view("test1")
        waitTrackingAgentHasNoCommandsNotification {
            XCTAssertEqual(self.circuitBreaker.count, 0)
        }
        
        // status: 400 の時はリトライしない(失敗にカウントしない)
        self.removeStub(self.stub)
        self.stub = stub(uri("/v0/native/track"), badRequestResponse)
        Tracker.view("test2")
        waitTrackingAgentHasNoCommandsNotification {
            XCTAssertEqual(self.circuitBreaker.count, 0)
        }
        
        self.removeStub(self.stub)
    }
    
    func testTrackClientWithRetry() throws {
        let serverErrorResponse = StubBuilder(test: self, resource: .failure_server_error).build(status: 500)
        
        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        session.isAutoFlush = true
        reachabilityService.notify(true)
        
        // status: 500 の時はリトライする
        self.stub = stub(uri("/v0/native/track"), serverErrorResponse)
        
        // circuitBreakerが無効の時はmaxまでリトライする
        circuitBreaker.disable = true
        self.maxRetryCount = 5
        self.exp = keyValueObservingExpectation(for: circuitBreaker.counter, keyPath: "count", expectedValue: maxRetryCount + 1)
        Tracker.view("test1")
        wait(for: [self.exp], timeout: 20)
        XCTAssertTrue(self.circuitBreaker.canRequest)
        
        // circuitBreakerが有効の時は域値まで制限される
        circuitBreaker.reset()
        circuitBreaker.disable = false
        self.exp = keyValueObservingExpectation(for: circuitBreaker.counter, keyPath: "count", expectedValue: circuitBreaker.threshold)
        Tracker.view("test2")
        wait(for: [self.exp], timeout: 20)
        XCTAssertFalse(self.circuitBreaker.canRequest)
        
        self.removeStub(self.stub)
    }
}
