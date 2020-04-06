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

internal enum LogicalOperator: Codable {
    case and([Condition])

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var conditions: [Condition] = []
        if var nestedUnkeyedContainer = try? container.nestedUnkeyedContainer(forKey: .and) {
            while !nestedUnkeyedContainer.isAtEnd {
                do {
                    let condition = try nestedUnkeyedContainer.decode(Condition.self)
                    conditions.append(condition)
                } catch {
                    _ = try nestedUnkeyedContainer.decode(DummyDecodable.self)
                }
            }
        }

        if !conditions.isEmpty {
            self = .and(conditions)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "")
            throw DecodingError.typeMismatch(LogicalOperator.self, context)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .and(let conditions):
            try container.encode(conditions, forKey: .and)
        }
    }

    func match(data: [String: JSONValue]) -> Bool {
        switch self {
        case .and(let conditions):
            let matchedConditions = conditions.filter { condition -> Bool in
                condition.match(data: data)
            }
            return matchedConditions.count == conditions.count
        }
    }
}

extension LogicalOperator {
    struct DummyDecodable: Decodable {}

    enum CodingKeys: String, CodingKey {
        case and = "$and"
    }
}
