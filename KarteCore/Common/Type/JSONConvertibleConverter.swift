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

/// JSONConvertible型への変換用ヘルパーメソッドを提供します。
public enum JSONConvertibleConverter {
    /// JSONConvertible型へ変換します。<br>
    /// なお変換不能な値は、nil値として取り扱います。
    ///
    /// - Parameter value: 変換対象の配列
    /// - Returns: 変換済みの配列を返します。
    public static func convert(_ value: [Any]) -> [JSONConvertible] {
        value.map { convert($0) }
    }

    /// JSONConvertible型へ変換します。<br>
    /// なお変換不能な値は、nil値として取り扱います。
    ///
    /// - Parameter value: 変換対象の辞書
    /// - Returns: 変換済みの辞書を返します。
    public static func convert(_ value: [String: Any]) -> [String: JSONConvertible] {
        value.mapValues { convert($0) }
    }

    /// JSONConvertible型へ変換します。<br>
    /// なお変換不能な値は、nil値として取り扱います。
    ///
    /// - Parameter value: 変換対象の値
    /// - Returns: 変換済みの値を返します。
    public static func convert(_ value: Any) -> JSONConvertible {
        switch value {
        case let string as String:
            return string

        case let number as NSNumber:
            return convert(number)

        case let date as Date:
            return date

        case let array as [Any]:
            return array.map { convert($0) }

        case let dictionary as [String: Any]:
            return dictionary.mapValues { convert($0) }

        default:
            return NSNull()
        }
    }

    private static func convert(_ number: NSNumber) -> JSONConvertible {
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        let objCType = String(cString: number.objCType)
        switch objCType {
        case "c", "C", "B":
            return number.boolValue

        case "i", "s", "l", "q":
            return number.intValue

        case "I", "S", "L", "Q":
            return number.uintValue

        case "f", "d":
            return number.doubleValue

        default:
            return NSNull()
        }
    }
}
