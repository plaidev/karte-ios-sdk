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

class TrackClientTests: XCTestCase {
    var session: TrackClientSessionMock!
    var reachabilityService: ReachabilityServiceMock!
    var exp: XCTestExpectation!
    var stub: Stub!
    
    override func setUpWithError() throws {
        Resolver.registerMockServices()
        
        let session = TrackClientSessionMock()
        self.session = session
        
        let reachabilityService = ReachabilityServiceMock()
        self.reachabilityService = reachabilityService
        
        Resolver.root = Resolver.submock
        Resolver.root.register {
            session as TrackClientSession
        }
        Resolver.root.register { (_, _) -> ReachabilityService in
            reachabilityService as ReachabilityService
        }
        
        KarteApp.shared.teardown()
    }

    override func tearDownWithError() throws {
        Resolver.root = Resolver.mock
        KarteApp.shared.teardown()
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

        self.exp = expectation(forNotification: TrackingAgent.trackingAgentHasNoCommandsNotification, object: nil) { [weak self] (_) -> Bool in
            guard let self = self else {
                return true
            }
            self.removeStub(self.stub)
            self.exp.fulfill()
            return true
        }
        
        wait(for: [exp], timeout: 20)
    }
}
