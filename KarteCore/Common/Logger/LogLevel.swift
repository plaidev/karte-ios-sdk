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

/// ログレベルを表す列挙型です。
@objc(KRTLogLevel)
public enum LogLevel: Int, Comparable {
    /// Off
    case off
    /// Error
    case error
    /// Warning
    case warn
    /// Information
    case info
    /// Debug
    case debug
    /// Verbose
    case verbose

    var identifier: String {
        switch self {
        case .off:
            return "-"
        case .error:
            return "E"
        case .warn:
            return "W"
        case .info:
            return "I"
        case .debug:
            return "D"
        case .verbose:
            return "V"
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
