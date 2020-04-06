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

internal class DefaultPubSub: PubSub {
    var publishers: [PubSubPublisherId: PubSubPublisher] = [:]
    var subscribers: [PubSubTopic: PubSubSubscriber] = [:]
    var registrar: PubSubRegistrar
    var sorter: PubSubSorter
    var deliverers: [PubSubDeliverer]

    var isSuspend: Bool = false {
        didSet {
            guard oldValue != self.isSuspend else {
                return
            }
            if self.isSuspend {
                deliverers.forEach { $0.stopDelivery() }
            } else {
                deliverers.forEach { $0.startDelivery() }
            }
        }
    }

    init() {
        let database = SQLiteDatabase(name: "karte.sqlite")
        self.registrar = DefaultPubSubRegistrar(database)

        let defaultDeliverer = DefaultPubSubDeliverer(topic: .default)
        let retryDeliverer = DefaultPubSubDeliverer(topic: .retry)
        self.deliverers = [defaultDeliverer, retryDeliverer]

        let sorter = DefaultPubSubSorter()
        sorter.dispatchers = [
            DefaultPubSubDispatcher(.default, deliverer: defaultDeliverer),
            DefaultPubSubDispatcher(.retry, deliverer: retryDeliverer)
        ]
        self.sorter = sorter

        defaultDeliverer.delegate = self
        retryDeliverer.delegate = self
    }

    deinit {
    }
}
