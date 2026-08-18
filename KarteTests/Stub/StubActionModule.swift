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
@testable import KarteCore

class StubActionModule {
    typealias TrackResponseData = (request: URLRequest, body: TrackBody, event: Event)

    private let metadataLabel: String

    var exp: XCTestExpectation
    var stub: Stub?

    var request: URLRequest?
    var responses: [String: TrackResponseData] = [:]

    init(metadata: Any? = nil, stub: Stub?) {
        self.metadataLabel = metadata.map { String(describing: $0) } ?? "test"
        self.exp = XCTestExpectation(description: "Wait for finish => \(metadataLabel)")
        self.stub = stub

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeTrackingAgentHasNoCommandsNotification(_:)),
            name: TrackingAgent.trackingAgentHasNoCommandsNotification,
            object: nil
        )

        KarteApp.shared.register(module: .action(self))
    }

    convenience init(metadata: Any? = nil, path: String = "/v0/native/track", builder: @escaping Builder) {
        self.init(metadata: metadata, stub: nil)

        self.stub = HTTPStubProtocol.addStub(
            matcher: HTTPStubProtocol.pathMatcher(path),
            builder: { [weak self] request in
                self?.request = request
                return builder(request)
            }
        )
    }

    @discardableResult
    func wait(timeout: TimeInterval = 10) -> StubActionModule {
        let result = XCTWaiter.wait(for: [self.exp], timeout: timeout)
        if result != .completed {
            XCTFail("""
            Expectation not fulfilled: \(result)
            metadata=\(metadataLabel)
            request=\(request?.description ?? "<none>")
            receivedEvents=\(responses.keys.sorted())
            isReachable=\(TrackClient.shared.isReachable)
            state=\(TrackClient.shared.state)
            isSending=\(TrackClient.shared.isSending)
            pendingEvents=\(TrackClient.shared.tasks.map { task in
                task.request.commands.map { $0.event.eventName.rawValue }
            })
            """)
        }
        return self
    }

    @discardableResult
    func verify(timeout: TimeInterval = 10) -> StubActionModule {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(timeout) - 1)) {
            self.finish()
        }
        let result = XCTWaiter.wait(for: [self.exp], timeout: timeout)
        if result != .completed {
            XCTFail("""
            Expectation not fulfilled: \(result)
            metadata=\(metadataLabel)
            request=\(request?.description ?? "<none>")
            receivedEvents=\(responses.keys.sorted())
            isReachable=\(TrackClient.shared.isReachable)
            state=\(TrackClient.shared.state)
            isSending=\(TrackClient.shared.isSending)
            pendingEvents=\(TrackClient.shared.tasks.map { task in
                task.request.commands.map { $0.event.eventName.rawValue }
            })
            """)
        }
        return self
    }

    func finish() {
        if let stub = stub {
            HTTPStubProtocol.removeStub(stub)
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
