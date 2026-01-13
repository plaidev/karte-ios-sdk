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
import Mockingjay
import XCTest
@testable import KarteCore

class StubActionModule {
    typealias TrackResponseData = (request: URLRequest, body: TrackBody, event: Event)

    var exp: XCTestExpectation
    var testCase: XCTestCase
    var stub: Stub?

    var request: URLRequest?
    var responses: [String: TrackResponseData] = [:]

    init(_ testCase: Any, metadata: ExampleMetadata? = nil, stub: Stub?) {
        let metadataLabel = metadata?.example.name ?? "test"

        // Accept both QuickSpec and QuickSpec.Type
        if let spec = testCase as? XCTestCase {
            self.testCase = spec
        } else if testCase is XCTestCase.Type {
            // For class methods, try to get the current test instance
            // This is a workaround for Quick 7.x where spec() is a class method
            self.testCase = XCTestCase()
        } else {
            fatalError("testCase must be XCTestCase or XCTestCase.Type")
        }

        self.exp = self.testCase.expectation(description: "Wait for finish => \(metadataLabel)")
        self.stub = stub
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeTrackingAgentHasNoCommandsNotification(_:)),
            name: TrackingAgent.trackingAgentHasNoCommandsNotification,
            object: nil
        )
        
        KarteApp.shared.register(module: .action(self))
    }
    
    convenience init(_ testCase: Any, metadata: ExampleMetadata? = nil, path: String = "/v0/native/track", builder: @escaping Builder) {
        // Initialize without stub first
        self.init(testCase, metadata: metadata, stub: nil)

        // Now create stub using MockingjayProtocol.addStub directly (works in both instance and class method contexts)
        // We can now capture self since initialization is complete
        self.stub = MockingjayProtocol.addStub(matcher: uri(path), builder: { [weak self] (request) -> (Response) in
            self?.request = request
            return builder(request)
        })
    }

    @discardableResult
    func wait(timeout: TimeInterval = 10) -> StubActionModule {
        testCase.wait(for: [self.exp], timeout: timeout)
        return self
    }

    @discardableResult
    func verify(timeout: TimeInterval = 10) -> StubActionModule {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(timeout) - 1)) {
            self.finish()
        }
        testCase.wait(for: [self.exp], timeout: timeout)
        return self
    }

    func finish() {
        if let stub = stub {
            MockingjayProtocol.removeStub(stub)
        }
        KarteApp.shared.unregister(module: .action(self))

        NotificationCenter.default.removeObserver(
            self, name: TrackingAgent.trackingAgentHasNoCommandsNotification,
            object: nil
        )

        exp.fulfill()
    }
    
    func responseData(_ eventName: EventName) -> TrackResponseData? {
        return responses[eventName.rawValue]
    }
    
    func responseDatas(_ eventNames: [EventName]) -> [TrackResponseData] {
        return eventNames.compactMap { self.responses[$0.rawValue] }
    }
    
    func request(_ eventName: EventName) -> URLRequest? {
        return responses[eventName.rawValue]?.request
    }
    
    func body(_ eventName: EventName) -> TrackBody? {
        return responses[eventName.rawValue]?.body
    }
    
    func event(_ eventName: EventName) -> Event? {
        return responses[eventName.rawValue]?.event
    }
    
    func events(_ eventNames: [EventName]) -> [Event] {
        return eventNames.compactMap { self.responses[$0.rawValue]?.event }
    }
    
    @objc private func observeTrackingAgentHasNoCommandsNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.finish()
        }
    }
}

extension StubActionModule: ActionModule {
    
    var name: String {
        return String(describing: type(of: self))
    }
    
    var queue: DispatchQueue? {
        return nil
    }
    
    func receive(response: [String : JSONValue], request: TrackRequest) {
        guard let req = self.request, let body = req.trackBody() else {
            return
        }
        
        self.responses = body.events.reduce(responses) { dict, event in
            var dict = dict
            dict[event.eventName.rawValue] = (req, body, event)
            return dict
        }
    }
    
    func reset(sceneId: SceneId) {
    }
    
    func resetAll() {
    }
}
