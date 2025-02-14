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
import KarteCore
import KarteUtilities

/// 設定値とそれに付随する情報を保持するためのクラスです。<br>
/// 設定値の他に、接客サービスIDやアクションIDを保持しています。
@objc(KRTVariable)
public class Variable: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case campaignId
        case shortenId
        case name
        case value
        case timestamp
        case eventHash
    }

    /// キャンペーンIDを返します。<br>
    /// 設定値が未定義の場合は `nil` を返します。
    @objc public var campaignId: String?

    /// アクションIDを返します。<br>
    /// 設定値が未定義の場合は `nil` を返します。
    @objc public var shortenId: String?

    /// 設定値名を返します。
    @objc public var name: String

    /// 設定値を返します。<br>
    /// 設定値が未定義の場合は `nil` を返します。
    var value: String?

    @objc public var timestamp: String?
    @objc public var eventHash: String?

    /// 設定値が定義済みであるかどうか返します。<br>
    /// 定義済みの場合は `true` を、未定義の場合は `false` を返します。
    @objc public var isDefined: Bool {
        value != nil
    }

    /// 設定値（文字列）を返します。<br>
    /// 設定値が未定義の場合は `nil` を返します。
    @objc public var string: String? {
        value
    }

    /// 設定値（配列）を返します。<br>
    /// 以下の場合において nil を返します。
    /// - 設定値が未定義の場合
    /// - 設定値（JSON文字列）のパースができない場合
    @objc public var array: [Any]? {
        // swiftlint:disable:previous discouraged_optional_collection
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            return object as? [Any]
        } catch {
            Logger.error(tag: .variables, message: "Failed to parse JSON: \(error)")
            return nil
        }
    }

    /// 設定値（辞書）を返します。<br>
    /// 以下の場合において nil を返します。
    /// - 設定値が未定義の場合
    /// - 設定値（JSON文字列）のパースができない場合
    @objc public var dictionary: [String: Any]? {
        // swiftlint:disable:previous discouraged_optional_collection
        guard let data = string?.data(using: .utf8) else {
            return nil
        }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            return object as? [String: Any]
        } catch {
            Logger.error(tag: .variables, message: "Failed to parse JSON: \(error)")
            return nil
        }
    }

    /// 設定値インスタンスを初期化します。
    /// - Parameter name: 設定値名
    @objc
    public init(name: String) {
        self.name = name

        let key = UserDefaultsKey(name, forNamespace: .variables)
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            do {
                let variable = try JSONDecoder().decode(Variable.self, from: data)
                self.campaignId = variable.campaignId
                self.shortenId = variable.shortenId
                self.value = variable.value
                self.timestamp = variable.timestamp
                self.eventHash = variable.eventHash
            } catch {
                Logger.verbose(tag: .variables, message: "Failed to decode JSON. \(error)")
            }
        } else {
            Logger.warn(tag: .variables, message: "Variable is not found. name=\(name)")
        }
        super.init()
    }

    init(name: String, campaignId: String, shortenId: String, value: String?, timestamp: String?, eventHash: String?) {
        self.name = name
        self.campaignId = campaignId
        self.shortenId = shortenId
        self.value = value
        self.timestamp = timestamp
        self.eventHash = eventHash
        super.init()
    }

    /// 設定値（文字列）を返します。<br>
    /// なお設定値が未定義の場合は、デフォルト値を返します。
    ///
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（文字列）
    @objc(stringWithDefaultValue:)
    public func string(default value: String) -> String {
        if let string = self.string {
            return string
        } else {
            return value
        }
    }

    /// 設定値（整数）を返します。<br>
    /// なお設定値が数値でない場合は、デフォルト値を返します。
    ///
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（整数）
    @objc(integerWithDefaultValue:)
    public func integer(default value: Int) -> Int {
        guard let string = string else {
            return value
        }
        if isNumeric(string) {
            return (string as NSString).integerValue
        } else {
            return value
        }
    }

    /// 設定値（浮動小数点数）を返します。<br>
    /// なお設定値が数値でない場合は、デフォルト値を返します。
    ///
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（浮動小数点数）
    @objc(doubleWithDefaultValue:)
    public func double(default value: Double) -> Double {
        guard let string = string else {
            return value
        }
        if isNumeric(string) {
            return (string as NSString).doubleValue
        } else {
            return value
        }
    }

    /// 設定値（ブール値）を返します。<br>
    /// なおブール値への変換ルールについては [こちら](https://developer.apple.com/documentation/foundation/nsstring/1409420-boolvalue) を参照してください。
    ///
    /// 設定値が未定義の場合は、デフォルト値を返します。
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（ブール値）
    @objc(boolWithDefaultValue:)
    public func bool(default value: Bool) -> Bool {
        guard let string = string else {
            return value
        }
        return (string as NSString).boolValue
    }

    /// 設定値（配列）を返します。<br>
    /// 以下の場合においてデフォルト値を返します。
    /// - 設定値が未定義の場合
    /// - 設定値（JSON文字列）のパースができない場合
    ///
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（配列）
    @objc(arrayWithDefaultValue:)
    public func array(default value: [Any]) -> [Any] {
        array ?? value
    }

    /// 設定値（辞書）を返します。<br>
    /// 以下の場合においてデフォルト値を返します。
    /// - 設定値が未定義の場合
    /// - 設定値（JSON文字列）のパースができない場合
    ///
    /// - Parameter value: デフォルト値
    /// - Returns: 設定値（辞書）
    @objc(dictionaryWithDefaultValue:)
    public func dictionary(default value: [String: Any]) -> [String: Any] {
        dictionary ?? value
    }

    func save() {
        guard let campaignId = campaignId, let shortenId = shortenId else {
            Logger.warn(tag: .variables, message: "Failed to save because value is nil.")
            return
        }
        Logger.debug(tag: .variables, message: "Write variable: \(name). campaignId=\(campaignId), shortenId=\(shortenId)")

        do {
            let data = try JSONEncoder().encode(self)
            let key = UserDefaultsKey(name, forNamespace: .variables)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            Logger.verbose(tag: .variables, message: "Failed to encode JSON. \(error)")
        }
    }

    func clear() {
        let key = UserDefaultsKey(name, forNamespace: .variables)
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func isNumeric(_ value: String) -> Bool {
        let intScanner = Scanner(string: value)
        if intScanner.scanInt(nil) && intScanner.isAtEnd {
            return true
        }

        let doubleScanner = Scanner(string: value)
        if doubleScanner.scanDouble(nil) && doubleScanner.isAtEnd {
            return true
        }

        return false
    }

    deinit {
    }
}
