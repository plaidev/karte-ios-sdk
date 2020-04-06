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

internal typealias TrackingSuccessful = (TrackRequest, TrackResponse.Response) -> Void
internal typealias TrackingFailure = (TrackRequest, SessionTaskError) -> Void

internal protocol TrackingSubscriber: PubSubSubscriber {
}

extension TrackingSubscriber {
    func send(_ request: TrackRequest, from deliverer: PubSubDeliverer, successful: TrackingSuccessful? = nil, failure: TrackingFailure? = nil) {
        func _successful(request: TrackRequest, response: TrackResponse.Response?) {
            if let response = response {
                kCommonQueue.async {
                    successful?(request, response)
                }
            } else {
                Logger.verbose(tag: .track, message: "Response is empty.")
            }

            let messages = request.dataSets.map { $0.message }
            deliverer.accept(messages)
        }

        func _failure(request: TrackRequest, error: SessionTaskError) {
            Logger.error(tag: .track, message: "Failed to send request: \(error)")

            kCommonQueue.async {
                failure?(request, error)
            }

            let messages = request.dataSets.map { $0.message }
            deliverer.reject(messages)
        }

        TrackClient.shared.send(request, queue: kCommonQueue, successful: _successful, failure: _failure)
    }
}
