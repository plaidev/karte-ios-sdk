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

internal struct UploadLogRequest: Request {
    typealias Response = String

    let url: URL
    let file: Data?

    var baseURL: URL {
        url
    }

    var method: HTTPMethod {
        .put
    }

    var path: String {
        ""
    }

    var headerFields: [String: String] {
        [
            "Content-Encoding": "gzip"
        ]
    }

    var bodyParameters: BodyParameters? {
        guard let file = file, let gzipped = try? gzipped(file) else {
            return nil
        }
        return DataBodyParameters(data: gzipped)
    }

    var dataParser: DataParser {
        StringDataParser()
    }

    init(url: URL, file: URL) {
        self.url = url
        self.file = try? Data(contentsOf: file)
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 120.0
        return urlRequest
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> String {
        guard let status = object as? String else {
            return ""
        }
        return status
    }
}

private struct DataBodyParameters: BodyParameters {
    var data: Data
    var contentType: String {
        "text/plain; charset=utf-8"
    }
    init(data: Data) {
        self.data = data
    }
    func buildEntity() throws -> RequestBodyEntity {
        .data(data)
    }
}
