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
import KarteDetectors
import KarteUtilities

public struct AppInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case versionName        = "version_name"
        case versionCode        = "version_code"
        case karteSdkVersion    = "karte_sdk_version"
        case moduleInfo         = "module_info"
        case systemInfo         = "system_info"
    }
    /// アプリケーションのバージョン番号（CFBundleShortVersionString）を返します。
    @OptionalCodableInjected(name: "app_info.version_name")
    public var versionName: String?

    /// アプリケーションのビルド番号（CFBundleVersion）を返します。
    @OptionalCodableInjected(name: "app_info.version_code")
    public var versionCode: String?

    /// KARTE Core SDKのバージョン番号を返します。
    @OptionalCodableInjected(name: "app_info.karte_sdk_version")
    public var karteSdkVersion: String?

    /// KARTE SDKの各モジュールバージョンを返します。
    @CodableInjected(name: "app_info.module_info")
    public var moduleInfo: [String: String]

    /// System情報を返します。
    @CodableInjected(name: "app_info.system_info")
    public var systemInfo: SystemInfo

    init() {
    }
}

extension Resolver {
    static func registerAppInfo() {
        register(String.self, name: "app_info.version_name") {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
        register(String.self, name: "app_info.version_code") {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        }
        register(String.self, name: "app_info.karte_sdk_version") {
            KRTCoreCurrentLibraryVersion()
        }
        register([String: String].self, name: "app_info.module_info") {
            var modules = KarteApp.libraries.reduce(into: [String: String]()) { modules, library in
                if library.isPublic {
                    modules[library.name] = library.version
                }
            }
            modules["core"] = KRTCoreCurrentLibraryVersion()
            modules["utilities"] = KRTUtilitiesCurrentLibraryVersion()
            modules["detectors"] = KRTDetectorsCurrentLibraryVersion()
            return modules
        }
        register(SystemInfo.self, name: "app_info.system_info") {
            SystemInfo()
        }
    }
}
