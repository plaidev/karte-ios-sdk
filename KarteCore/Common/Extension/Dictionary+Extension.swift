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

extension Dictionary where Key == String, Value == JSONValue {
    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた値がある場合はそれを返し、ない場合は nil を返します。
    public func value(forKeyPath keyPath: String) -> JSONValue? {
        var val: JSONValue? = .dictionary(self)
        for component in keyPath.split(separator: ".") {
            let key = String(component)
            if let index = Int(key) {
                val = value(atIndex: index, value: val)
            } else {
                val = value(forKey: key, value: val)
            }
        }

        return val
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた文字列値がある場合はそれを返し、ない場合や値型が文字列型でない場合は nil を返します。
    public func string(forKeyPath keyPath: String) -> String? {
        value(forKeyPath: keyPath)?.rawValue as? String
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられたブール値がある場合はそれを返し、ない場合や値型がブール型でない場合は nil を返します。
    public func bool(forKeyPath keyPath: String) -> Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        return value(forKeyPath: keyPath)?.rawValue as? Bool
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた整数値がある場合はそれを返し、ない場合や値型が整数型でない場合は nil を返します。
    public func integer(forKeyPath keyPath: String) -> Int? {
        value(forKeyPath: keyPath)?.rawValue as? Int
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた浮動小数点値がある場合はそれを返し、ない場合や値型が浮動小数点型でない場合は nil を返します。
    public func double(forKeyPath keyPath: String) -> Double? {
        value(forKeyPath: keyPath)?.rawValue as? Double
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた日付値がある場合はそれを返し、ない場合や値型が日付型でない場合は nil を返します。
    public func date(forKeyPath keyPath: String) -> Date? {
        guard let val = value(forKeyPath: keyPath)?.rawValue else {
            return nil
        }

        switch val {
        case let val as Date:
            return val

        case let val as Double:
            return Date(timeIntervalSince1970: val)

        default:
            return nil
        }
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた配列値がある場合はそれを返し、ない場合や値型が配列型でない場合は nil を返します。
    public func array(forKeyPath keyPath: String) -> [Any]? {
        guard let val = value(forKeyPath: keyPath) else {
            return nil
        }
        switch val {
        case .array(let array):
            return array.map { $0.rawValue }

        default:
            return nil
        }
    }

    /// 指定されたキーパスに関連付けられた値にアクセスします。
    /// - Parameter keyPath: 辞書を検索するためのキーパス
    /// - Returns: キーパスに関連付けられた辞書値がある場合はそれを返し、ない場合や値型が辞書型でない場合は nil を返します。
    public func dictionary(forKeyPath keyPath: String) -> [String: Any]? {
        guard let val = value(forKeyPath: keyPath) else {
            return nil
        }
        switch val {
        case .dictionary(let dictionary):
            return dictionary.mapValues { $0.rawValue }

        default:
            return nil
        }
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた値がある場合はそれを返し、ない場合は nil を返します。
    public func value(forKey key: String) -> Any? {
        value(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた文字列値がある場合はそれを返し、ない場合や値型が文字列型でない場合は nil を返します。
    public func string(forKey key: String) -> String? {
        string(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられたブール値がある場合はそれを返し、ない場合や値型がブール型でない場合は nil を返します。
    public func bool(forKey key: String) -> Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        return bool(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた整数値がある場合はそれを返し、ない場合や値型が整数型でない場合は nil を返します。
    public func integer(forKey key: String) -> Int? {
        integer(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた浮動小数点値がある場合はそれを返し、ない場合や値型が浮動小数点型でない場合は nil を返します。
    public func double(forKey key: String) -> Double? {
        double(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた日付値がある場合はそれを返し、ない場合や値型が日付型でない場合は nil を返します。
    public func date(forKey key: String) -> Date? {
        date(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた配列値がある場合はそれを返し、ない場合や値型が配列型でない場合は nil を返します。
    public func array(forKey key: String) -> [Any]? {
        array(forKeyPath: key)
    }

    /// 指定されたキーに関連付けられた値にアクセスします。
    /// - Parameter key: 辞書を検索するためのキー
    /// - Returns: キーに関連付けられた辞書値がある場合はそれを返し、ない場合や値型が辞書型でない場合は nil を返します。
    public func dictionary(forKey key: String) -> [String: Any]? {
        dictionary(forKeyPath: key)
    }

    private func value(forKey key: String, value: JSONValue?) -> JSONValue? {
        guard let value = value else {
            return nil
        }
        switch value {
        case .dictionary(let dictionary):
            return dictionary[key]

        default:
            return nil
        }
    }

    private func value(atIndex index: Int, value: JSONValue?) -> JSONValue? {
        guard let value = value else {
            return nil
        }
        switch value {
        case .array(let array):
            return array.count > index ? array[index] : nil

        default:
            return nil
        }
    }
}
