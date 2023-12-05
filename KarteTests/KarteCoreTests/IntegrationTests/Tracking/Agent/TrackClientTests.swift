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
import Mockingjay
import Nimble
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
            session as TrackClientSession
        }
        Resolver.root.register { (_, _) -> ReachabilityService in
            reachabilityService as ReachabilityService
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

    func testTrackClient() throws {
        self.stub = stub(uri("/v0/native/track"), StubBuilder(test: self, resource: .empty).build())
        
        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        session.isAutoFlush = false
        reachabilityService.notify(true)
        
        Tracker.view("test1")
        Tracker.view("test2")
        Tracker.view("test3")
        Tracker.view("test4")

        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(1)) {
            expect(self.session.tasks.count).to(equal(1))
            expect(TrackClient.shared.tasks.count).to(equal(3))
            expect(TrackClient.shared.state).to(equal(.running))
            self.session.flush()
        }
        
        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(3)) {
            expect(self.session.tasks.count).to(equal(1))
            expect(TrackClient.shared.tasks.count).to(equal(2))
            expect(TrackClient.shared.state).to(equal(.running))
            self.reachabilityService.notify(false)
        }
        
        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(5)) {
            expect(self.session.tasks.count).to(equal(1))
            expect(TrackClient.shared.tasks.count).to(equal(2))
            expect(TrackClient.shared.state).to(equal(.running))
            self.session.flush()
        }

        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(7)) {
            expect(self.session.tasks.count).to(equal(0))
            expect(TrackClient.shared.tasks.count).to(equal(1))
            expect(TrackClient.shared.state).to(equal(.running))
            self.reachabilityService.notify(true)
        }
        
        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(9)) {
            expect(self.session.tasks.count).to(equal(1))
            expect(TrackClient.shared.tasks.count).to(equal(1))
            expect(TrackClient.shared.state).to(equal(.running))
            self.session.flush()
        }
        
        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(11)) {
            expect(self.session.tasks.count).to(equal(1))
            expect(TrackClient.shared.tasks.count).to(equal(1))
            expect(TrackClient.shared.state).to(equal(.running))
            self.session.flush()
        }

        TrackClient.shared.callbackQueue.asyncAfter(deadline: .now() + .seconds(13)) {
            expect(self.session.tasks.count).to(equal(0))
            expect(TrackClient.shared.tasks.count).to(equal(0))
            expect(TrackClient.shared.state).to(equal(.waiting))
        }
        
        waitTrackingAgentHasNoCommandsNotification()
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
            expect(self.circuitBreaker.count).to(equal(0))
        }
        
        // status: 400 の時はリトライしない(失敗にカウントしない)
        self.removeStub(self.stub)
        self.stub = stub(uri("/v0/native/track"), badRequestResponse)
        Tracker.view("test2")
        waitTrackingAgentHasNoCommandsNotification {
            expect(self.circuitBreaker.count).to(equal(0))
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
        Tracker.view("test1")
        self.exp = keyValueObservingExpectation(for: circuitBreaker.counter, keyPath: "count", expectedValue: maxRetryCount + 1)
        wait(for: [self.exp], timeout: 20)
        expect(self.circuitBreaker.canRequest).to(beTrue())
        
        // circuitBreakerが有効の時は域値まで制限される
        circuitBreaker.reset()
        circuitBreaker.disable = false
        Tracker.view("test2")
        self.exp = keyValueObservingExpectation(for: circuitBreaker.counter, keyPath: "count", expectedValue: circuitBreaker.threshold)
        wait(for: [self.exp], timeout: 20)
        expect(self.circuitBreaker.canRequest).to(beFalse())
        
        self.removeStub(self.stub)
    }
}
