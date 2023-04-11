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

import CoreGraphics
import Foundation
/// JSON値を表す列挙型です。
public indirect enum JSONValue {
    /// nil
    case none
    /// 文字列型
    case string(String)
    /// ブール型
    case bool(Bool)
    /// 符号つき整数型
    case int(Int)
    /// 符号つき整数型（8bit）
    case int8(Int8)
    /// 符号つき整数型（16bit）
    case int16(Int16)
    /// 符号つき整数型（32bit）
    case int32(Int32)
    /// 符号つき整数型（64bit）
    case int64(Int64)
    /// 符号なし整数型
    case uint(UInt)
    /// 符号なし整数型（8bit）
    case uint8(UInt8)
    /// 符号なし整数型（16bit）
    case uint16(UInt16)
    /// 符号なし整数型（32bit）
    case uint32(UInt32)
    /// 符号なし整数型（64bit）
    case uint64(UInt64)
    /// 浮動小数点型
    case double(Double)
    /// 浮動小数点型
    case float(Float)
    /// 浮動小数点型
    case cgfloat(CGFloat)
    /// 日付型
    case date(Date)
    /// 配列型
    case array([JSONValue])
    /// 辞書型
    case dictionary([String: JSONValue])

    /// `JSONConvertible` を返します。
    public var rawValue: JSONConvertible {
        switch self {
        case .none:
            return NSNull()

        case .string(let string):
            return string

        case .bool(let bool):
            return bool

        case .int(let int):
            return int

        case .int8(let int8):
            return int8

        case .int16(let int16):
            return int16

        case .int32(let int32):
            return int32

        case .int64(let int64):
            return int64

        case .uint(let uint):
            return uint

        case .uint8(let uint8):
            return uint8

        case .uint16(let uint16):
            return uint16

        case .uint32(let uint32):
            return uint32

        case .uint64(let uint64):
            return uint64

        case .double(let double):
            return double

        case .float(let float):
            return float

        case .cgfloat(let cgfloat):
            return cgfloat

        case .date(let date):
            return date

        case .array(let array):
            return array.map { $0.rawValue }

        case .dictionary(let dictionary):
            return dictionary.mapValues { $0.rawValue }
        }
    }
}

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let int64 = try? container.decode(Int64.self) {
            self = .int64(int64)
        } else if let uint = try? container.decode(UInt.self) {
            self = .uint(uint)
        } else if let uint64 = try? container.decode(UInt64.self) {
            self = .uint64(uint64)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: JSONValue].self) {
            self = .dictionary(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "JSONValue value cannot be decoded")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            try container.encodeNil()

        case .string(let string):
            try container.encode(string)

        case .bool(let bool):
            try container.encode(bool)

        case .int(let int):
            try container.encode(int)

        case .int8(let int8):
            try container.encode(int8)

        case .int16(let int16):
            try container.encode(int16)

        case .int32(let int32):
            try container.encode(int32)

        case .int64(let int64):
            try container.encode(int64)

        case .uint(let uint):
            try container.encode(uint)

        case .uint8(let uint8):
            try container.encode(uint8)

        case .uint16(let uint16):
            try container.encode(uint16)

        case .uint32(let uint32):
            try container.encode(uint32)

        case .uint64(let uint64):
            try container.encode(uint64)

        case .double(let double):
            try container.encode(double)

        case .float(let float):
            try container.encode(float)

        case .cgfloat(let cgfloat):
            try container.encode(cgfloat)

        case .date(let date):
            try container.encode(date)

        case .array(let array):
            try container.encode(array)

        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }
}

extension Dictionary where Key == String, Value == JSONValue {
    mutating func mergeRecursive(_ other: [Key: Value]) {
        merge(other, uniquingKeysWith: resolveConflict)
    }

    func mergingRecursive(_ other: [Key: Value]) -> [Key: Value] {
        return merging(other, uniquingKeysWith: resolveConflict)
    }

    func resolveConflict(_ lhs: Value, _ rhs: Value) -> Value {
        switch (lhs, rhs) {
        case (.dictionary(let lhs), .dictionary(let rhs)):
            return .dictionary(lhs.mergingRecursive(rhs))
        default:
            return rhs
        }
    }
}
