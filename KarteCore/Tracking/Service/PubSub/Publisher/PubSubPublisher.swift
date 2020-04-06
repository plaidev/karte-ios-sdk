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

internal protocol PubSubPublisherDelegate: AnyObject {
    func publisher(_ publisher: PubSubPublisher, didReceive message: PubSubMessage, error: Error?)
}

internal protocol PubSubPublisher {
    var delegate: PubSubPublisherDelegate? { get set }
    var id: PubSubPublisherId { get }
    var delayQueue: DispatchQueue { get }

    func publish(to pubsub: PubSub, topic: PubSubTopic, message: PubSubMessage)
    func receive(_ result: PubSubResult, from pubsub: PubSub)
    func receiveRetryable(_ messages: [PubSubMessage], from pubsub: PubSub)
}

extension PubSubPublisher {
    func publish(to pubsub: PubSub, topic: PubSubTopic, message: PubSubMessage) {
        pubsub.publish(topic, message: message)
    }

    func receive(_ result: PubSubResult, from pubsub: PubSub) {
        switch result {
        case let .success(_, message):
            delegate?.publisher(self, didReceive: message, error: nil)

        case let .failure(_, message):
            delegate?.publisher(self, didReceive: message, error: PubSubError.reject)
            guard message.isRetryable else {
                return
            }
            do {
                let deadline = try message.exponentialBackoff.nextDelay()
                delayQueue.asyncAfter(deadline: .now() + deadline) {
                    self.publish(to: pubsub, topic: .retry, message: message)
                }
            } catch {
                Logger.warn(tag: .track, message: "The maximum number of retries has been reached.")
            }
        }
    }

    func receiveRetryable(_ messages: [PubSubMessage], from pubsub: PubSub) {
        messages.forEach { message in
            publish(to: pubsub, topic: .retry, message: message)
        }
    }
}

internal struct PubSubPublisherId: Hashable {
    var id: String

    init(_ id: String) {
        self.id = id
    }
}

internal protocol UsesPubSubPublisher {
    var publisher: PubSubPublisher { get }
}
