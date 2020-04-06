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

internal struct TrackClient {
    static let shared = TrackClient()

    private let semaphore: DispatchSemaphore

    private init() {
        self.semaphore = DispatchSemaphore(value: 0)
    }

    func send(_ request: TrackRequest, queue: DispatchQueue, successful: @escaping (TrackRequest, TrackResponse.Response?) -> Void, failure: @escaping (TrackRequest, SessionTaskError) -> Void) {
        Logger.debug(tag: .track, message: "Request start. request_id=\(request.requestId) retry=\(request.isRetry)")
        request.dataSets.forEach { dataSet in
            let reqId = request.requestId
            let msgId = dataSet.message.messageId.id
            let name = dataSet.data.event.eventName.rawValue

            let message = "Event included in the request. request_id=\(reqId) message_id=\(msgId) event_name=\(name)"
            Logger.verbose(tag: .track, message: message)
        }
        Session.send(request, callbackQueue: .dispatchQueue(queue)) { result in
            Logger.debug(tag: .track, message: "Request end. request_id=\(request.requestId)")

            switch result {
            case let .success(response):
                successful(request, response.response)

            case let .failure(error):
                failure(request, error)
            }
            self.semaphore.signal()
        }

        semaphore.wait()
    }
}
