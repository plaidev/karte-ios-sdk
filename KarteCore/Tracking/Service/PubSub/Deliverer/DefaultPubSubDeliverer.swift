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

internal class DefaultPubSubDeliverer: PubSubDeliverer {
    weak var delegate: PubSubDelivererDelegate?

    var topic: PubSubTopic
    var subscriber: PubSubSubscriber? {
        didSet {
            guard oldValue == nil else {
                return
            }
            deliver(messages, completion: complation)
        }
    }

    var isUnderDelivery: Bool {
        !messages.isEmpty
    }

    var messages: [PubSubMessage]
    var complation: (() -> Void)?
    var executionQueue: DispatchQueue

    init(topic: PubSubTopic) {
        self.topic = topic
        self.messages = []
        self.executionQueue = DispatchQueue(
            label: "io.karte.pubsub.queue.execution-\(topic.name)",
            qos: DispatchQoS(qosClass: .utility, relativePriority: 100)
        )
    }

    func startDelivery() {
        executionQueue.resume()
    }

    func stopDelivery() {
        executionQueue.suspend()
    }

    func deliver(_ messages: [PubSubMessage], completion: (() -> Void)?) {
        self.messages = messages
        self.complation = completion

        guard !messages.isEmpty else {
            Logger.warn(tag: .track, message: "Messages is empty.")
            return
        }
        guard let subscriber = subscriber else {
            Logger.warn(tag: .track, message: "Subscriber isn't registered.")
            return
        }

        self.executionQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            subscriber.receive(messages, topic: self.topic, from: self)
        }
    }

    func accept(_ messages: [PubSubMessage]) {
        self.messages.removeAll { message -> Bool in
            let ret = messages.contains { $0.messageId == message.messageId }
            return ret
        }
        notify()
        delegate?.deliverer(self, didAccept: messages, topic: topic)
    }

    func reject(_ messages: [PubSubMessage]) {
        self.messages.removeAll { message -> Bool in
            let ret = messages.contains { $0.messageId == message.messageId }
            return ret
        }
        notify()
        delegate?.deliverer(self, didReject: messages, topic: topic)
    }

    func notify() {
        guard messages.isEmpty else {
            return
        }
        complation?()
    }

    deinit {
    }
}
