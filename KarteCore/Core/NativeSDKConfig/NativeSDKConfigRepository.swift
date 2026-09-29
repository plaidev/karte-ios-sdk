//
//  Copyright 2026 PLAID, Inc.
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
import KarteUtilities

extension UserDefaultsKey {
    static let nativeSDKConfig = UserDefaultsKey("native_sdk_config", forNamespace: .config)
}

struct NativeSDKConfigCache: Codable {
    let flags: [String: Bool]
    let fetchedAt: Date
    let ttl: TimeInterval

    func isExpired(now: Date = Date()) -> Bool {
        now.timeIntervalSince(fetchedAt) > ttl
    }
}

protocol NativeSDKConfigRepository {
    func load() -> NativeSDKConfigCache?
    func save(_ cache: NativeSDKConfigCache)
}

struct DefaultNativeSDKConfigRepository: NativeSDKConfigRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> NativeSDKConfigCache? {
        guard let data = userDefaults.object(forKey: .nativeSDKConfig) as? Data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(NativeSDKConfigCache.self, from: data)
        } catch {
            Logger.error(tag: .core, message: "NativeSDKConfig cache decode failed: \(error)")
            userDefaults.removeObject(forKey: .nativeSDKConfig)
            return nil
        }
    }

    func save(_ cache: NativeSDKConfigCache) {
        do {
            let data = try JSONEncoder().encode(cache)
            userDefaults.set(data, forKey: .nativeSDKConfig)
        } catch {
            Logger.error(tag: .core, message: "NativeSDKConfig cache encode failed: \(error)")
        }
    }
}
