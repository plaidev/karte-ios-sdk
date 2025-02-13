//
//  Copyright 2024 PLAID, Inc.
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
import KarteVariables

struct VariableParser {
    private static let keyPrefix = "KRT_IN_APP_FRAME$"
    private static let versionKey = "version"
    private static let typeKey = "componentType"
    private static let contentKey = "content"

    static func parse(for key: String) -> InAppFrameArg? {
        let iafKey = keyPrefix+key
        guard let data = Variables.variable(forKey: iafKey).string?.data(using: .utf8) else {
            Logger.warn(tag: .inAppFrame, message: "Failed to get Variable for PlacementID: \(iafKey)")
            return nil
        }
        return parse(for: iafKey, data)
    }

    static func parse(for key: String, _ data: Data) -> InAppFrameArg? {
        guard let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = InAppFrameVersion(rawValue: parsed[versionKey] as? String ?? ""),
              let componentType = ComponentType(rawValue: parsed[typeKey] as? String ?? ""),
              let content = parsed[contentKey] else {
            Logger.warn(tag: .inAppFrame, message: "Failed to parse InAppFrame data")
            return nil
        }

        guard let rawContent = try? JSONSerialization.data(withJSONObject: content) else {
            Logger.warn(tag: .inAppFrame, message: "Failed to parse rawContent")
            return nil
        }

        let arg: InAppFrameArg
        switch componentType {
        case .iafCarousel:
            switch version {
            case .v1:
                guard let model = try? JSONDecoder().decode(InAppCarouselModel.self, from: rawContent) else {
                    Logger.warn(tag: .inAppFrame, message: "Failed to parse \(InAppCarouselModel.self)")
                    return nil
                }
                arg = InAppFrameArg(keyName: key, version: version, componentType: .iafCarousel, content: model)
            }
        }

        return arg
    }
}
