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

internal struct TraceRequest: Request {
    typealias Response = String

    let configuration: Configuration
    let appKey: String
    let appInfo: AppInfo
    let visitorId: String
    let account: Account
    let action: ActionProtocol
    let image: Data?

    var baseURL: URL {
        configuration.baseURL
    }

    var method: HTTPMethod {
        .post
    }

    var path: String {
        "/v0/native/auto-track/trace"
    }

    var headerFields: [String: String] {
        [
            "X-KARTE-App-Key": appKey,
            "X-KARTE-Auto-Track-Account-Id": account.id
        ]
    }

    var bodyParameters: BodyParameters? {
        var parts: [MultipartFormDataBodyParameters.Part] = []

        if let data = try? createJSONEncoder().encode(PartData(action: action, appInfo: appInfo, visitorId: visitorId)) {
            let part = MultipartFormDataBodyParameters.Part(data: data, name: "trace")
            parts.append(part)
        }

        if let image = image {
            let part = MultipartFormDataBodyParameters.Part(data: image, name: "image", mimeType: "image/jpeg", fileName: "image")
            parts.append(part)
        }

        return MultipartFormDataBodyParameters(parts: parts)
    }

    var dataParser: DataParser {
        StringDataParser()
    }

    init?(app: KarteApp, account: Account, action: ActionProtocol, image: Data?) {
        guard let appInfo = app.appInfo else {
            return nil
        }
        self.configuration = app.configuration
        self.appKey = app.appKey
        self.appInfo = appInfo
        self.visitorId = app.visitorId
        self.account = account
        self.action = action
        self.image = image
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 10.0
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> String {
        guard let status = object as? String else {
            return ""
        }
        return status
    }
}

extension TraceRequest {
    struct PartData: Codable {
        var os: String
        var visitorId: String
        var values: Values

        init(action: ActionProtocol, appInfo: AppInfo, visitorId: String) {
            self.os = "iOS"
            self.visitorId = visitorId
            self.values = Values(action: action, appInfo: appInfo)
        }
    }
}

extension TraceRequest.PartData {
    struct Values: Codable {
        var action: String
        var actionId: String?
        var view: String?
        var viewController: String?
        var targetText: String?
        var appInfo: AppInfo

        init(action: ActionProtocol, appInfo: AppInfo) {
            self.action = action.action
            self.actionId = action.actionId
            self.view = action.screenName
            self.viewController = action.screenHostName
            self.targetText = action.targetText
            self.appInfo = appInfo
        }
    }

    enum CodingKeys: String, CodingKey {
        case os
        case visitorId  = "visitor_id"
        case values
    }
}

extension TraceRequest.PartData.Values {
    enum CodingKeys: String, CodingKey {
        case action
        case actionId       = "action_id"
        case view
        case viewController = "view_controller"
        case targetText     = "target_text"
        case appInfo        = "app_info"
    }
}
