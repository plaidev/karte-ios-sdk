//
//  Copyright 2022 PLAID, Inc.
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

protocol BaseAPIRequest {
    associatedtype Response where Response: Decodable

    var apiKey: String { get }
    var config: InboxConfig { get }
    var version: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyParams: [String: Any]? { get }
}

extension BaseAPIRequest {
    var apiKey: String {
        Inbox.currentApiKey
    }

    var version: String {
        "/v2native"
    }

    var headers: [String: String] {
        [
            "Content-Type": "application/json; charset=utf-8",
            "X-KARTE-Api-Key": apiKey
        ]
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var bodyParams: [String: Any]? {
        nil
    }

    func asURLRequest() -> URLRequest {
        var urlComponents = URLComponents(string: "\(config.baseUrl.absoluteString)\(version)/\(path)")!
        urlComponents.queryItems = queryItems
        var req = URLRequest(url: urlComponents.url!)
        req.allHTTPHeaderFields = headers
        req.httpMethod = method.rawValue
        if let params = bodyParams {
            req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        }
        return req
    }
}
