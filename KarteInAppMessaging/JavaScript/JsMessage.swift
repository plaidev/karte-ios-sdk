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
import WebKit

internal enum JsMessage: CustomStringConvertible {
    case event(EventData)
    case stateChanged(StateChangedData)
    case openUrl(OpenURLData)
    case visibility(VisibilityData)

    var description: String {
        switch self {
        case .event(let data):
            return "event=\(data.eventName.rawValue)"
        case .stateChanged(let data):
            return "state_changed=\(data.state?.rawValue ?? "unknown")"
        case .openUrl(let data):
            return "open_url=\(data.url?.absoluteString ?? "unknown")"
        case .visibility(let data):
            return "visibility=\(data.state.rawValue)"
        }
    }

    init(scriptMessage: WKScriptMessage) throws {
        guard JSONSerialization.isValidJSONObject(scriptMessage.body),
              let data = try? JSONSerialization.data(withJSONObject: scriptMessage.body, options: .fragmentsAllowed) else {
            throw JsMessageError.invalidBody
        }
        guard let name = JsMessageName(rawValue: scriptMessage.name) else {
            throw JsMessageError.invalidName
        }

        switch name {
        case .event:
            self = .event(try EventData(data))

        case .stateChanged:
            self = .stateChanged(try StateChangedData(data))

        case .openURL:
            self = .openUrl(try OpenURLData(data))

        case .visibility:
            self = .visibility(try VisibilityData(data))
        }
    }
}

extension JsMessage {
    struct EventData: Decodable {
        var eventName: EventName
        var values: [String: JSONValue]

        init(_ body: Data) throws {
            self = try createJSONDecoder().decode(type(of: self).self, from: body)
        }
    }

    struct StateChangedData: Decodable {
        var state: JsState?

        init(_ body: Data) throws {
            self = try createJSONDecoder().decode(type(of: self).self, from: body)
        }
    }

    struct OpenURLData: Decodable {
        var url: URL?
        var target: String?

        var isTargetBlank: Bool {
            target == "_blank"
        }

        init(_ body: Data) throws {
            self = try createJSONDecoder().decode(type(of: self).self, from: body)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let urlString = try container.decode(String.self, forKey: .url)
            self.url = conformToRFC2396(urlString: urlString)
            self.target = try container.decode(String.self, forKey: .target)
        }
    }

    struct VisibilityData: Decodable {
        var state: WidgetsState

        init(_ body: Data) throws {
            self = try createJSONDecoder().decode(type(of: self).self, from: body)
        }
    }
}

extension JsMessage.EventData {
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case values
    }
}

extension JsMessage.OpenURLData {
    enum CodingKeys: String, CodingKey {
        case url
        case target
    }
}
