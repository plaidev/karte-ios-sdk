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

internal class DefaultReachabilityService: ReachabilityService {
    private var reachability: Reachability?
    var whenReachable: ReachabilityService.Reachable?
    var whenUnreachable: ReachabilityService.Unrachable?

    init(baseURL: URL) {
        do {
            // swiftlint:disable:next force_unwrapping
            let reachability = try Reachability(hostname: baseURL.host!)
            reachability.whenReachable = { [weak self] _ in
                self?.notify(true)
            }
            reachability.whenUnreachable = { [weak self] _ in
                self?.notify(false)
            }
            self.reachability = reachability
        } catch {
            Logger.error(tag: .track, message: "Reachability initialization failed. \(error)")
        }
    }

    func startNotifier() {
        try? reachability?.startNotifier()
    }

    func stopNotifier() {
        reachability?.stopNotifier()
    }

    func notify(_ isReachable: Bool) {
        if isReachable {
            whenReachable?()
        } else {
            whenUnreachable?()
        }
    }

    deinit {
    }
}
