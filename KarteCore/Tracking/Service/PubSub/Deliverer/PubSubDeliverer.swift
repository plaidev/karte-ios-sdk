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

internal protocol PubSubDelivererDelegate: AnyObject {
    func deliverer(_ deliverer: PubSubDeliverer, didAccept messages: [PubSubMessage], topic: PubSubTopic)
    func deliverer(_ deliverer: PubSubDeliverer, didReject messages: [PubSubMessage], topic: PubSubTopic)
}

internal protocol PubSubDeliverer {
    var delegate: PubSubDelivererDelegate? { get set }
    var topic: PubSubTopic { get }
    var subscriber: PubSubSubscriber? { get set }
    var isUnderDelivery: Bool { get }

    mutating func regist(_ subscriber: PubSubSubscriber)
    mutating func unregist()

    func startDelivery()
    func stopDelivery()
    func deliver(_ messages: [PubSubMessage], completion: (() -> Void)?)
    func accept(_ messages: [PubSubMessage])
    func reject(_ messages: [PubSubMessage])
}

extension PubSubDeliverer {
    mutating func regist(_ subscriber: PubSubSubscriber) {
        self.subscriber = subscriber
    }

    mutating func unregist() {
        self.subscriber = nil
    }
}

internal protocol UsesPubSubDeliverer {
    var deliverers: [PubSubDeliverer] { get }
}
