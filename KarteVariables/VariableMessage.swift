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

internal struct VariableMessage: Codable {
    struct Action: Codable {
        var shortenId: String?
        var type: String?
        var content: Content?
        var noAction: Bool?
        var reason: String?
        var responseTimestamp: String

        var responseId: String? {
            guard let shortenId = shortenId else {
                return nil
            }
            return "\(responseTimestamp)_\(shortenId)"
        }
    }

    struct Campaign: Codable {
        var campaignId: String?
        var serviceActionType: String?
    }

    struct Trigger: Codable {
        var eventHashes: String
    }

    var action: Action
    var campaign: Campaign
    var trigger: Trigger

    var isEnabled: Bool {
        guard campaign.campaignId != nil, action.shortenId != nil else {
            return false
        }

        guard campaign.serviceActionType == "remote_config" else {
            return false
        }

        return true
    }

    var isControlGroup: Bool {
        action.type == "control"
    }

    static func from(message: [String: JSONValue]) -> VariableMessage? {
        guard let data = try? createJSONEncoder().encode(message) else {
            return nil
        }
        return try? createJSONDecoder().decode(VariableMessage.self, from: data)
    }
}

extension VariableMessage.Action {
    enum CodingKeys: String, CodingKey {
        case shortenId          = "shorten_id"
        case type
        case content
        case noAction           = "no_action"
        case reason
        case responseTimestamp  = "response_timestamp"
    }

    struct Content: Codable {
        // swiftlint:disable:next discouraged_optional_collection
        var inlinedVariables: [InlinedVariable]?
    }
}

extension VariableMessage.Action.Content {
    enum CodingKeys: String, CodingKey {
        case inlinedVariables = "inlined_variables"
    }

    struct InlinedVariable: Codable {
        var name: String?
        var value: String?
    }
}

extension VariableMessage.Campaign {
    enum CodingKeys: String, CodingKey {
        case campaignId         = "_id"
        case serviceActionType  = "service_action_type"
    }
}

extension VariableMessage.Trigger {
    enum CodingKeys: String, CodingKey {
        case eventHashes = "event_hashes"
    }
}
