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

internal class TimeWindowBundleRule: AsyncCommandBundleRule {
    let queue: DispatchQueue
    let interval: DispatchTimeInterval
    var isImmediatelyBundlable = true

    init(queue: DispatchQueue, interval: DispatchTimeInterval) {
        self.queue = queue
        self.interval = interval
    }

    func schedule(bundle: CommandBundle, command: TrackingCommand, completion: @escaping BundleCompletionBlock) {
        queue.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let rule = self else {
                return
            }

            guard rule.evaluate(bundle: bundle, command: command) else {
                return completion(false)
            }

            if rule.isImmediatelyBundlable {
                return completion(true)
            }

            rule.schedule(bundle: bundle, command: command, completion: completion)
        }
    }

    func evaluate(bundle: CommandBundle, command: TrackingCommand) -> Bool {
        if bundle.isFrozen {
            return false
        }
        return bundle.last == command
    }

    deinit {
    }
}

extension TimeWindowBundleRule: TrackClientObserver {
    func trackClient(_ client: TrackClient, didChangeState state: TrackClientState) {
        self.isImmediatelyBundlable = state == .waiting
    }
}
