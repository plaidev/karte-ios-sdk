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

internal protocol PubSubSorter: UsesPubSubDispatcher {
    func sort(_ topic: PubSubTopic, message: PubSubMessage)
}

extension PubSubSorter {
    func sort(_ topic: PubSubTopic, message: PubSubMessage) {
        dispatchers.filter { $0.topic == topic }.forEach { $0.dispatch(message) }
    }
}

internal protocol UsesPubSubSorter {
    var sorter: PubSubSorter { get }
}
