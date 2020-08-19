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

import Foundation
import KarteUtilities

internal protocol TrackClientObserver: AnyObject {
    func trackClient(_ client: TrackClient, didChangeState state: TrackClientState)
}

internal class TrackClient {
    struct Task {
        var request: TrackRequest
        var completion: (Result<TrackRequest.Response, SessionTaskError>) -> Void
    }

    static let shared = TrackClient()

    private let clientQueue = DispatchQueue(
        label: "io.karte.tracking.network",
        qos: .utility
    )

    private (set) var state = TrackClientState.waiting
    private (set) var tasks = [Task]()
    private (set) var observers = [TrackClientObserver]()

    private (set) var reachability: ReachabilityService?
    private (set) var isReachable = false
    private (set) var isSending = false

    private (set) var callbackQueue = DispatchQueue.main

    private init() {
    }

    func configure(app: KarteApp, callbackQueue: DispatchQueue) {
        let reachability = Resolver.resolve(ReachabilityService.self, args: app.configuration.baseURL)
        reachability.whenReachable = { [weak self] in
            Logger.info(tag: .track, message: "Communication is possible.")
            self?.callbackQueue.async {
                self?.isReachable = true
                self?.send()
                self?.updateState()
            }
        }
        reachability.whenUnreachable = { [weak self] in
            Logger.info(tag: .track, message: "Communication is impossible.")
            self?.callbackQueue.async {
                self?.isReachable = false
                self?.updateState()
            }
        }
        reachability.startNotifier()

        self.reachability = reachability
        self.callbackQueue = callbackQueue
    }

    func enqueue(request: TrackRequest, completion: @escaping (Result<TrackRequest.Response, SessionTaskError>) -> Void) {
        let task = Task(request: request, completion: completion)
        tasks.append(task)

        guard state == .waiting else {
            return
        }
        updateState()
        send(task: task)
    }

    func addObserver(_ observer: TrackClientObserver) {
        if isContainsObserver(observer) {
            return
        }
        observers.append(observer)
    }

    func removeObserver(_ observer: TrackClientObserver) {
        guard isContainsObserver(observer) else {
            return
        }
        let identifier = ObjectIdentifier(observer)
        observers.removeAll { observer0 -> Bool in
            ObjectIdentifier(observer0) == identifier
        }
    }

    func teardown() {
        self.reachability?.stopNotifier()
        self.reachability = nil
        self.isReachable = false
        self.callbackQueue = DispatchQueue.main
        self.state = .waiting
        self.tasks.removeAll()
        self.observers.removeAll()
    }

    deinit {
    }
}

private extension TrackClient {
    func send(task: Task) {
        self.isSending = true
        clientQueue.async { [weak self] in
            guard let callbackQueue = self?.callbackQueue else {
                return
            }

            Logger.debug(tag: .track, message: "Request start. request_id=\(task.request.requestId) retry=\(task.request.isRetry)")
            for command in task.request.commands {
                let reqId = task.request.requestId
                let cmdId = command.identifier
                let name = command.event.eventName.rawValue

                let message = "Event included in the request. request_id=\(reqId) command_id=\(cmdId) event_name=\(name)"
                Logger.verbose(tag: .track, message: message)
            }

            let session = Resolver.resolve(TrackClientSession.self)
            session.send(task.request, callbackQueue: .dispatchQueue(callbackQueue)) { result in
                Logger.debug(tag: .track, message: "Request end. request_id=\(task.request.requestId)")
                self?.isSending = false

                self?.dequeue()
                task.completion(result)
            }
        }
    }

    func updateState() {
        let previousState = self.state

        if isReachable {
            self.state = tasks.isEmpty && !isSending ? .waiting : .running
        } else {
            self.state = .running
        }

        if self.state != previousState {
            for observer in observers {
                observer.trackClient(self, didChangeState: self.state)
            }
        }
    }

    func dequeue() {
        tasks.removeFirst()
        updateState()
        send()
    }

    func send() {
        if let task = tasks.first, isReachable, !isSending {
            send(task: task)
        }
    }

    func isContainsObserver(_ observer: TrackClientObserver) -> Bool {
        observers.map { observer -> ObjectIdentifier in
            ObjectIdentifier(observer)
        }.contains(ObjectIdentifier(observer))
    }
}

extension Resolver {
    static func registerTrackClientSession() {
        let session = DefaultTrackClientSession()
        register { session as TrackClientSession }
    }

    static func registerReachabilityService() {
        register { _, arg -> ReachabilityService in
            let baseURL = arg as? URL ?? KarteApp.shared.configuration.baseURL
            return DefaultReachabilityService(baseURL: baseURL)
        }
    }
}
