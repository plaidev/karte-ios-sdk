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

internal let kCommonQueue = DispatchQueue(label: "io.karte.pubsub.queue.common", qos: .utility)

internal enum PubSubError: Swift.Error {
    case reject
}

internal enum PubSubResult {
    case success(PubSubTopic, PubSubMessage)
    case failure(PubSubTopic, PubSubMessage)
}

internal protocol PubSub: UsesPubSubRegistrar, UsesPubSubSorter, UsesPubSubDeliverer, PubSubDelivererDelegate {
    var isSuspend: Bool { get set }
    var count: Int { get }

    var publishers: [PubSubPublisherId: PubSubPublisher] { get set }
    var subscribers: [PubSubTopic: PubSubSubscriber] { get set }

    func regist(publisher: PubSubPublisher)
    func regist(subscriber: PubSubSubscriber, topic: PubSubTopic)

    func publish(_ topic: PubSubTopic, message: PubSubMessage)

    func teardown()
}

extension PubSub {
    var count: Int {
        registrar.count
    }

    func regist(publisher: PubSubPublisher) {
        if publishers[publisher.id] != nil {
            Logger.warn(tag: .track, message: "Publisher is already registered. \(publisher.id)")
            return
        }
        publishers[publisher.id] = publisher

        publisher.receiveRetryable(registrar.retryable(publisherId: publisher.id), from: self)
    }

    func regist(subscriber: PubSubSubscriber, topic: PubSubTopic) {
        if subscribers[topic] != nil {
            Logger.warn(tag: .track, message: "Subscriber is already registered. \(topic)")
            return
        }
        subscribers[topic] = subscriber

        if var deliverer = deliverers.first(where: { $0.topic == topic }) {
            deliverer.regist(subscriber)
        }
    }

    func publish(_ topic: PubSubTopic, message: PubSubMessage) {
        registrar.accept(message)
        sorter.sort(topic, message: message)
    }

    func deliverer(_ deliverer: PubSubDeliverer, didAccept messages: [PubSubMessage], topic: PubSubTopic) {
        registrar.reached(messages)
        notify()

        func _dispatch() {
            for message in messages {
                publishers[message.publisherId]?.receive(.success(topic, message), from: self)
            }
        }
        kCommonQueue.async(execute: _dispatch)
    }

    func deliverer(_ deliverer: PubSubDeliverer, didReject messages: [PubSubMessage], topic: PubSubTopic) {
        registrar.notReached(messages)
        notify()

        func _dispatch() {
            for message in messages {
                publishers[message.publisherId]?.receive(.failure(topic, message), from: self)
            }
        }
        kCommonQueue.async(execute: _dispatch)
    }

    func teardown() {
        registrar.teardown()
    }

    private func notify() {
        let cnt = registrar.count
        guard cnt == 0 else {
            return
        }
        let notification = Notification(name: .pubsubQueueDidEmptyNotification)
        NotificationCenter.default.post(notification)
    }
}

internal protocol UsesPubSub {
    var pubsub: PubSub { get }
}

extension Notification.Name {
    static let pubsubQueueDidEmptyNotification = Notification.Name("io.karte.pubsub.queue.empty")
}
