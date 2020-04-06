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

internal enum ComparisonOperator: Codable {
    case eq(String)
    case ne(String)
    case startsWith(String)
    case endsWith(String)
    case contains(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .eq) {
            self = .eq(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .ne) {
            self = .ne(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .startsWith) {
            self = .startsWith(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .endsWith) {
            self = .endsWith(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .contains) {
            self = .contains(value)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "")
            throw DecodingError.typeMismatch(ComparisonOperator.self, context)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .eq(let value):
            try container.encode(value, forKey: .eq)

        case .ne(let value):
            try container.encode(value, forKey: .ne)

        case .startsWith(let value):
            try container.encode(value, forKey: .startsWith)

        case .endsWith(let value):
            try container.encode(value, forKey: .endsWith)

        case .contains(let value):
            try container.encode(value, forKey: .contains)
        }
    }

    func match(value val: String) -> Bool {
        switch self {
        case .eq(let value):
            return val == value

        case .ne(let value):
            return val != value

        case .startsWith(let value):
            return val.hasPrefix(value)

        case .endsWith(let value):
            return val.hasSuffix(value)

        case .contains(let value):
            return val.contains(value)
        }
    }
}

extension ComparisonOperator {
    enum CodingKeys: String, CodingKey {
        case eq         = "$eq"
        case ne         = "$ne"
        case startsWith = "$startsWith"
        case endsWith   = "$endsWith"
        case contains   = "$contains"
    }
}
