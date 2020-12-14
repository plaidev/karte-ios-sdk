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

internal struct DefinitionsRequest: Request {
    typealias Response = DefinitionsResponse

    let configuration: Configuration
    let appKey: String
    let definitionsLastModified: Int

    var baseURL: URL {
        configuration.baseURL
    }

    var method: HTTPMethod {
        .get
    }

    var path: String {
        "/v0/native/auto-track/definitions"
    }

    var headerFields: [String: String] {
        [
            "X-KARTE-App-Key": appKey,
            "X-KARTE-Auto-Track-OS": "iOS",
            "X-KARTE-Auto-Track-If-Modified-Since": String(definitionsLastModified)
        ]
    }

    var dataParser: DataParser {
        StringDataParser()
    }

    init(app: KarteApp, definitionsLastModified: Int) {
        self.configuration = app.configuration
        self.appKey = app.appKey
        self.definitionsLastModified = definitionsLastModified
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 10.0
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> DefinitionsResponse {
        guard let str = object as? String, let data = str.data(using: .utf8)  else {
            throw ResponseError.unexpectedObject(object)
        }
        return try createJSONDecoder().decode(DefinitionsResponse.self, from: data)
    }
}

extension DefinitionsRequest {
    struct DefinitionsResponse: Codable {
        var success: Int
        var status: Int
        var response: AutoTrackDefinition?
        var error: String?
    }
}
