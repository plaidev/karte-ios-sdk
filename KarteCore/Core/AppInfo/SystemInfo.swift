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

import KarteUtilities
import UIKit

public struct SystemInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case os
        case osVersion  = "os_version"
        case device
        case model
        case bundleId   = "bundle_id"
        case idfv
        case idfa
        case language
        case screen
    }
    /// OS名を返します。
    @CodableInjected(name: "system_info.os")
    public var os: String

    /// OSバージョンを返します。
    @CodableInjected(name: "system_info.os_version")
    public var osVersion: String

    /// デバイス名を返します。
    @CodableInjected(name: "system_info.device")
    public var device: String

    /// デバイスモデル名を返します。
    @CodableInjected(name: "system_info.model")
    public var model: String

    /// バンドルIDを返します。
    @OptionalCodableInjected(name: "system_info.bundle_id")
    public var bundleId: String?

    /// 端末識別子を返します。
    @OptionalCodableInjected(name: "system_info.idfv")
    public var idfv: String?

    /// 広告識別子を返します。
    @OptionalCodableInjected(name: "system_info.idfa")
    public var idfa: String?

    /// 言語設定を返します。
    @OptionalCodableInjected(name: "system_info.language")
    public var language: String?

    /// スクリーンサイズ情報を返します。
    @CodableInjected(name: "system_info.screen")
    public var screen: Screen

    init() {
    }
}

extension Resolver {
    static func registerSystemInfo() {
        register(String.self, name: "system_info.os") {
            "iOS"
        }
        register(String.self, name: "system_info.os_version") {
            UIDevice.current.systemVersion
        }
        register(String.self, name: "system_info.device") {
            UIDevice.current.model
        }
        register(String.self, name: "system_info.model") {
            var systemInfo = utsname()
            uname(&systemInfo)

            let identifier = Mirror(reflecting: systemInfo.machine).children.reduce(into: "") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else {
                    return
                }
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
            return identifier
        }
        register(String.self, name: "system_info.bundle_id") {
            Bundle.main.bundleIdentifier
        }
        register(String.self, name: "system_info.idfv") {
            UIDevice.current.identifierForVendor?.uuidString
        }
        register(String.self, name: "system_info.idfa") {
            guard let idfaDelegate = KarteApp.shared.configuration.idfaDelegate else {
                return nil
            }
            guard idfaDelegate.isAdvertisingTrackingEnabled else {
                return nil
            }
            return idfaDelegate.advertisingIdentifierString
        }
        register(String.self, name: "system_info.language") {
            Locale.preferredLanguages.first
        }
        register(Screen.self, name: "system_info.screen") {
            Screen()
        }
    }
}
