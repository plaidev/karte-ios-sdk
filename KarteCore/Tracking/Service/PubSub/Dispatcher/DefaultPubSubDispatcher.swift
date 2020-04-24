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

import KarteUtilities
import UIKit

internal class DefaultPubSubDispatcher: PubSubDispatcher {
    @Injected
    var application: PubSubApplication

    var deliverer: PubSubDeliverer
    var topic: PubSubTopic
    var queue: Queue<PubSubMessage>

    init(_ topic: PubSubTopic, deliverer: PubSubDeliverer) {
        self.topic = topic
        self.deliverer = deliverer

        let dispatchQueue = DispatchQueue(
            label: "io.karte.pubsub.queue.manipulation-\(topic.name)",
            qos: DispatchQoS(qosClass: .utility, relativePriority: 200)
        )
        self.queue = Queue(dispatchQueue)
    }

    func dispatch(_ message: PubSubMessage) {
        let applicationState = self.application.state

        queue.atomic.enqueue(message) {
            _run()
        }

        func _run() {
            queue.atomic.manipulator.asyncAfter(deadline: .now() + .milliseconds(500)) {
                guard let deliverer = _call() else {
                    return
                }

                let messages = _dequeue()
                if !messages.isEmpty {
                    deliverer.deliver(messages, completion: _run)
                }
            }
        }

        func _call() -> PubSubDeliverer? {
            guard !deliverer.isUnderDelivery else {
                return nil
            }
            return deliverer
        }

        func _dequeue() -> [PubSubMessage] {
            queue.dequeueLimit(10) { message -> Bool in
                if message.isReadyOnBackground {
                    return true
                }
                return applicationState != .background
            }
        }
    }

    deinit {
    }
}

extension Resolver {
    static func registerPubSubDispatcher() {
        let application = DefaultPubSubApplication()
        register { application as PubSubApplication }
    }
}
