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
@testable import KarteCore
@testable import KarteUtilities

public extension NotificationCenter {
    static let test = NotificationCenter()
}

class TrackClientSessionMock: TrackClientSession {
    static let requestSentNotification = Notification.Name("io.karte.test.trackClientSession.requestSent")

    struct Task {
        var request: TrackRequest
        var handler: (Result<TrackRequest.Response, NetworkingError>) -> Void
    }
    
    var isAutoFlush = true
    var tasks = [Task]()
    
    func send(_ request: TrackRequest, handler: @escaping (Result<TrackRequest.Response, NetworkingError>) -> Void) -> URLSessionTask? {
        let task = Task(request: request, handler: handler)
        if isAutoFlush {
            return send(task: task)
        } else {
            tasks.append(task)
            return nil
        }
    }
    
    func flush() {
        while !tasks.isEmpty {
            let task = tasks.removeFirst()
            send(task: task)
        }
    }
    
    @discardableResult
    func send(task: Task) -> URLSessionTask? {
        NotificationCenter.test.post(name: TrackClientSessionMock.requestSentNotification, object: task.request.commands.count)
        return Session.send(task.request, handler: task.handler)
    }
}
