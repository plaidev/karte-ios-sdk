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
@testable import KarteCore

class StubActionModule {
    var exp: XCTestExpectation
    var spec: QuickSpec
    var eventNames: [EventName]
    var receiver: ((URLRequest, TrackBodyParameters, Event) -> Void)?
    var stub: Stub?

    var request: URLRequest?

    init(_ spec: QuickSpec, metadata: ExampleMetadata?, builder: @escaping Builder, eventNames: [EventName], receiver: ((URLRequest, TrackBodyParameters, Event) -> Void)? = nil) {
        let metadataLabel = metadata?.example.name ?? "unknown"
        let eventNamesLabel = eventNames.map({ $0.rawValue }).joined(separator: ", ")
        
        self.exp = spec.expectation(description: "Wait for finish => \(metadataLabel) \(eventNamesLabel)")
        self.spec = spec
        self.eventNames = eventNames
        self.receiver = receiver
        
        self.stub = spec.stub(uri("/v0/native/track"), { [weak self] (request) -> (Response) in
            self?.request = request
            return builder(request)
        })
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observePubSubQueueDidEmptyNotification(_:)),
            name: .pubsubQueueDidEmptyNotification,
            object: nil
        )
        KarteApp.shared.register(module: .action(self))
    }

    convenience init(_ spec: QuickSpec, metadata: ExampleMetadata?, builder: @escaping Builder, eventName: EventName, receiver: ((URLRequest, TrackBodyParameters, Event) -> Void)? = nil) {
        self.init(spec, metadata: metadata, builder: builder, eventNames: [eventName], receiver: receiver)
    }
    
    func wait(timeout: TimeInterval = 10) {
        spec.wait(for: [self.exp], timeout: timeout)
    }
    
    func verify(timeout: TimeInterval = 10) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(timeout) - 1)) {
            self.finish()
        }
        spec.wait(for: [self.exp], timeout: timeout)
    }
    
    private func finish() {
        spec.removeStub(stub!)
        KarteApp.shared.unregister(module: .action(self))
        
        NotificationCenter.default.removeObserver(
            self,
            name: .pubsubQueueDidEmptyNotification,
            object: nil
        )
        
        exp.fulfill()
    }
    
    @objc private func observePubSubQueueDidEmptyNotification(_ notification: Notification) {
        kCommonQueue.async {
            DispatchQueue.main.async {
                self.finish()
            }
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
    
    func receive(response: TrackResponse.Response, request: TrackRequest) {
        guard let req = self.request, let body = req.trackBodyParameters() else {
            return
        }
        
        let events = eventNames.compactMap({ body.pick($0) })        
        for event in events {
            receiver?(req, body, event)
        }
    }
    
    func reset(sceneId: SceneId) {
    }
    
    func resetAll() {
    }
}
