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

internal class TrackingTaskCache {
    private var cache: [PubSubMessageId: TrackingTask] = [:]

    func addCache(_ task: TrackingTask, forKey key: PubSubMessageId) {
        objc_sync_enter(self)
        cache[key] = task
        objc_sync_exit(self)
    }

    func removeCache(forKey key: PubSubMessageId) -> TrackingTask? {
        objc_sync_enter(self)
        let task = cache.removeValue(forKey: key)
        objc_sync_exit(self)

        return task
    }

    deinit {
    }
}
