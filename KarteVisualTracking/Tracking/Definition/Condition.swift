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

internal struct Condition: Codable {
    var name: String
    var comparison: ComparisonOperator

    init(name: CodingKeys, comparison: ComparisonOperator) {
        self.name = name.rawValue
        self.comparison = comparison
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let codingKey = container.allKeys.first {
            let comparison = try container.decode(ComparisonOperator.self, forKey: codingKey)
            self.name = codingKey.rawValue
            self.comparison = comparison
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "")
            throw DecodingError.typeMismatch(Condition.self, context)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let codingKey = CodingKeys(rawValue: name) {
            try container.encode(comparison, forKey: codingKey)
        } else {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "")
            throw EncodingError.invalidValue(name, context)
        }
    }

    func match(data: [String: JSONValue]) -> Bool {
        guard let value = data.string(forKeyPath: name) else {
            return false
        }
        return comparison.match(value: value)
    }
}

extension Condition {
    enum CodingKeys: String, CodingKey {
        case action
        case view
        case viewController     = "view_controller"
        case targetText         = "target_text"
        case versionName        = "app_info.version_name"
        case versionCode        = "app_info.version_code"
        case karteSdkVersion    = "app_info.karte_sdk_version"
        case os                 = "app_info.system_info.os"
        case osVersion          = "app_info.system_info.os_version"
        case device             = "app_info.system_info.device"
        case model              = "app_info.system_info.model"
        case bundleId           = "app_info.system_info.bundle_id"
        case idfv               = "app_info.system_info.idfv"
        case idfa               = "app_info.system_info.idfa"
        case language           = "app_info.system_info.language"
        case actionId           = "action_id"
    }
}
