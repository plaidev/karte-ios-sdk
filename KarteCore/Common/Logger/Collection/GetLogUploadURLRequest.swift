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
import KarteUtilities

internal struct GetLogUploadURLRequest: Request {
    typealias Response = LogUploadURLResponse

    let appKey: String
    let visitorId: String
    let datePrefix: String
    let url: URL

    var baseURL: URL {
        url
    }

    var method: HTTPMethod {
        .post
    }

    var path: String {
        ""
    }

    var headerFields: [String: String] {
        [
            "X-KARTE-App-Key": appKey
        ]
    }
    var bodyParameters: BodyParameters? {
        GetURLRequestBodyParameters(visitorId: visitorId, localDate: datePrefix)
    }
    var dataParser: DataParser {
        RawDataParser()
    }
    init(app: KarteApp, datePrefix: String) {
        self.appKey = app.appKey
        self.visitorId = app.visitorId
        self.datePrefix = datePrefix
        self.url = app.configuration.logCollectionURL
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 10.0
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LogUploadURLResponse {
        guard let data = object as? Data else {
            throw GetLogUploadURLError()
        }
        return try createJSONDecoder().decode(LogUploadURLResponse.self, from: data)
    }
}

private struct GetURLRequestBodyParameters: BodyParameters, Codable {
    enum CodingKeys: String, CodingKey {
        case visitorId = "visitor_id"
        case localDate = "local_date"
    }
    var visitorId: String
    var localDate: String
    var contentType: String {
        "application/json"
    }
    init(visitorId: String, localDate: String) {
        self.visitorId = visitorId
        self.localDate = localDate
    }
    func buildEntity() throws -> RequestBodyEntity {
        let body = try createJSONEncoder().encode(self)
        return .data(body)
    }
}

internal struct LogUploadURLResponse: Codable {
    let url: URL?
}

internal struct GetLogUploadURLError: Error {}
