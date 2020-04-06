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

/// JSONに変換可能な値を表現するためのプロトコルです。
///
/// なおJSONとして扱うことが可能な型は、下記の通りです。
/// - String
/// - Bool
/// - Int
/// - UInt
/// - Double
/// - Float
/// - Date
/// - Array
/// - Dictionary
public protocol JSONConvertible {
    /// `JSONValue` を返します。
    var jsonValue: JSONValue { get }
}

extension NSNull: JSONConvertible {
    public var jsonValue: JSONValue {
        .none
    }
}

extension String: JSONConvertible {
    public var jsonValue: JSONValue {
        .string(self)
    }
}

extension Bool: JSONConvertible {
    public var jsonValue: JSONValue {
        .bool(self)
    }
}

extension Int: JSONConvertible {
    public var jsonValue: JSONValue {
        .int(self)
    }
}

extension Int8: JSONConvertible {
    public var jsonValue: JSONValue {
        .int8(self)
    }
}

extension Int16: JSONConvertible {
    public var jsonValue: JSONValue {
        .int16(self)
    }
}

extension Int32: JSONConvertible {
    public var jsonValue: JSONValue {
        .int32(self)
    }
}

extension Int64: JSONConvertible {
    public var jsonValue: JSONValue {
        .int64(self)
    }
}

extension UInt: JSONConvertible {
    public var jsonValue: JSONValue {
        .uint(self)
    }
}

extension UInt8: JSONConvertible {
    public var jsonValue: JSONValue {
        .uint8(self)
    }
}

extension UInt16: JSONConvertible {
    public var jsonValue: JSONValue {
        .uint16(self)
    }
}

extension UInt32: JSONConvertible {
    public var jsonValue: JSONValue {
        .uint32(self)
    }
}

extension UInt64: JSONConvertible {
    public var jsonValue: JSONValue {
        .uint64(self)
    }
}

extension Double: JSONConvertible {
    public var jsonValue: JSONValue {
        .double(self)
    }
}

extension Float: JSONConvertible {
    public var jsonValue: JSONValue {
        .float(self)
    }
}

extension CGFloat: JSONConvertible {
    public var jsonValue: JSONValue {
        .cgfloat(self)
    }
}

extension Date: JSONConvertible {
    public var jsonValue: JSONValue {
        .date(self)
    }
}

extension Array: JSONConvertible where Element == JSONConvertible {
    public var jsonValue: JSONValue {
        .array(self.map { $0.jsonValue })
    }
}

extension Dictionary: JSONConvertible where Key == String, Value == JSONConvertible {
    public var jsonValue: JSONValue {
        .dictionary(self.mapValues { $0.jsonValue })
    }
}
