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

internal protocol PubSubRegistrar: UsesPubSubRepository {
    var processId: String { get }
    var count: Int { get }

    func retryable(publisherId: PubSubPublisherId) -> [PubSubMessage]
    func accept(_ message: PubSubMessage)
    func reached(_ messages: [PubSubMessage])
    func notReached(_ messages: [PubSubMessage])
    func teardown()
}

extension PubSubRegistrar {
    var count: Int {
        repository.count
    }

    func retryable(publisherId: PubSubPublisherId) -> [PubSubMessage] {
        repository.retryable(publisherId: publisherId, processId: processId)
    }

    func accept(_ message: PubSubMessage) {
        guard message.isRetryable else {
            return
        }
        if repository.isAccepted(messageId: message.messageId) {
            Logger.info(tag: .track, message: "Message is already accepted. message_id=\(message.messageId.id)")
            return
        }
        repository.accept(message: message, processId: processId)
    }

    func reached(_ messages: [PubSubMessage]) {
        let messages = messages.filter { $0.isRetryable }
        for message in messages {
            repository.remove(messageId: message.messageId)
        }
    }

    func notReached(_ messages: [PubSubMessage]) {
        // NOP
    }

    func teardown() {
        repository.removeAll()
    }
}

internal protocol UsesPubSubRegistrar {
    var registrar: PubSubRegistrar { get }
}
