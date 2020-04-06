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

internal struct DefaultPubSubSubscriber: TrackingSubscriber {
    var id = PubSubSubscriberId("io.karte.pubsub.subscriber.default")
    var app: KarteApp

    init(app: KarteApp) {
        self.app = app
    }

    func receive(_ messages: [PubSubMessage], topic: PubSubTopic, from deliverer: PubSubDeliverer) {
        func successful(request: TrackRequest, response: TrackResponse.Response) {
            app.modules.forEach { module in
                if case let .action(module) = module {
                    guard let queue = module.queue else {
                        module.receive(response: response, request: request)
                        return
                    }
                    queue.async {
                        module.receive(response: response, request: request)
                    }
                }
            }
        }

        let requests = TrackRequestConverter.convert(app: app, messages: messages, isRetry: false)
        requests.forEach { send($0, from: deliverer, successful: successful) }
    }
}
