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

public enum ExponentialBackoffError: Error {
    case retryFailed
}

public class ExponentialBackoff: Codable {
    public enum CodingKeys: String, CodingKey {
        case interval
        case randomFactor
        case multiplier
        case maxCount
    }

    public var interval: TimeInterval
    public var randomFactor: Double
    public var multiplier: Int
    public var maxCount: Int
    public var count: Int = 0

    public init(interval: TimeInterval = 1.0, randomFactor: Double = 0.25, multiplier: Int = 2, maxCount: Int = 3) {
        self.interval = interval
        self.randomFactor = randomFactor
        self.multiplier = multiplier
        self.maxCount = maxCount
    }

    public func nextDelay() throws -> DispatchTimeInterval {
        count += 1

        if count > maxCount {
            throw ExponentialBackoffError.retryFailed
        }

        let nextInterval = interval * pow(Double(multiplier), Double(count - 1))
        let factor = (Double.random(in: 0 ... 1) * 2 * randomFactor) + 1 - randomFactor

        return .milliseconds(Int(nextInterval * factor * 1_000))
    }

    deinit {
    }
}
