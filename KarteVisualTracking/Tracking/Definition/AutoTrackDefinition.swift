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

internal struct AutoTrackDefinition: Codable {
    var status: Status
    var lastModified: Int?

    // swiftlint:disable:next discouraged_optional_collection
    var definitions: [Definition]?

    static func from(dictionary: [String: JSONValue]) throws -> AutoTrackDefinition {
        let data = try createJSONEncoder().encode(dictionary)
        let definition = try createJSONDecoder().decode(AutoTrackDefinition.self, from: data)
        return definition
    }

    func events(action: Action, appInfo: AppInfo) -> [Event] {
        let container = Container(
            action: action.action,
            view: action.viewName,
            viewController: action.viewControllerName,
            targetText: action.targetText,
            appInfo: appInfo,
            actionId: action.actionId
        )

        let data: [String: JSONValue]
        do {
            data = try container.convert()
        } catch {
            Logger.error(tag: .visualTracking, message: "Failed to convert data. \(error.localizedDescription)")
            return []
        }

        let events = (definitions ?? []).flatMap { definition -> [Event] in
            definition.events(data: data)
        }
        return events
    }
}

extension AutoTrackDefinition {
    enum Status: String, Codable {
        case modified
        case notModified = "not_modified"
    }

    enum CodingKeys: String, CodingKey {
        case status
        case lastModified = "last_modified"
        case definitions
    }

    internal struct Container: Encodable {
        var action: String
        var view: String?
        var viewController: String?
        var targetText: String?
        var appInfo: AppInfo
        var actionId: String?

        func convert() throws -> [String: JSONValue] {
            let data = try createJSONEncoder().encode(self)
            let dictionary = try createJSONDecoder().decode([String: JSONValue].self, from: data)
            return dictionary
        }
    }
}

extension AutoTrackDefinition.Container {
    enum CodingKeys: String, CodingKey {
        case action
        case view
        case viewController = "view_controller"
        case targetText     = "target_text"
        case appInfo        = "app_info"
        case actionId       = "action_id"
    }
}
