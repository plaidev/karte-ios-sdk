//
//  Copyright 2021 PLAID, Inc.
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

private let kTimeRecoverAfterSec: Double = 300

internal class CircuitBreaker {
    internal let threshold: Int
    internal let recoverAfter: Double
    private var failureCount = 0
    private var lastFailedAt = Date(timeIntervalSince1970: 0)

    var canRequest: Bool {
        if Date() > lastFailedAt.addingTimeInterval(recoverAfter) {
            reset()
        }
        return failureCount < threshold
    }

    init(threshold: Int = 3, recoverAfter: Double = kTimeRecoverAfterSec) {
        self.threshold = threshold
        self.recoverAfter = recoverAfter
    }

    func countFailure() {
        lastFailedAt = Date()
        failureCount += 1
    }

    func reset() {
        lastFailedAt = Date(timeIntervalSince1970: 0)
        failureCount = 0
    }
    deinit {
    }
}
