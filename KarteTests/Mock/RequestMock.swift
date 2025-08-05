//
//  Copyright 2025 PLAID, Inc.
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

import Quick
import Nimble
@testable import KarteUtilities

struct RequestMock: Request {
    typealias Response = String

    let baseURL: URL
    let method: HTTPMethod
    let path: String
    let headerFields: [String: String]
    let acceptableMediaType: String?
    private let _contentType: String
    let buildBodyResult: Data?
    let parseResult: String
    let shouldThrowFromBuildBody: Bool
    let shouldThrowFromParse: Bool

    init(
        baseURL: URL = URL(string: "https://example.com")!,
        method: HTTPMethod = .get,
        path: String = "",
        headerFields: [String: String] = [:],
        acceptableMediaType: String? = nil,
        contentType: String = "application/json",
        buildBodyResult: Data = Data(),
        parseResult: String = "success response",
        shouldThrowFromBuildBody: Bool = false,
        shouldThrowFromParse: Bool = false
    ) {
        self.baseURL = baseURL
        self.method = method
        self.path = path
        self.headerFields = headerFields
        self.acceptableMediaType = acceptableMediaType
        self._contentType = contentType
        self.buildBodyResult = buildBodyResult
        self.parseResult = parseResult
        self.shouldThrowFromBuildBody = shouldThrowFromBuildBody
        self.shouldThrowFromParse = shouldThrowFromParse
    }
    var contentType: String {
        _contentType
    }

    func buildBody() throws -> Data? {
        if shouldThrowFromBuildBody {
            throw NSError(domain: "MockBodyError", code: -1, userInfo: nil)
        }
        return buildBodyResult
    }

    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> String {
        if shouldThrowFromParse {
            throw NSError(domain: "RequestMockError", code: -1, userInfo: nil)
        }
        return parseResult
    }

}
