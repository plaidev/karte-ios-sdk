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
//  NOTE: The Implementation was inspired by APIKit.

import Foundation

public protocol Request {
    associatedtype Response

    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headerFields: [String: String] { get }
    var acceptableMediaType: String? { get }
    var contentType: String { get }

    func buildURLRequest() throws -> URLRequest
    func buildBody() throws -> Data?
    func statusCodeCheck(urlResponse: HTTPURLResponse) throws
    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response

}

public extension Request {
    var acceptableMediaType: String? {
        nil
    }

    func buildURLRequest() throws -> URLRequest {
        try buildBaseURLRequest()
    }

    func buildBaseURLRequest() throws -> URLRequest {
        let url: URL
        if path.isEmpty {
            url = baseURL
        } else {
            url = baseURL.appendingPathComponent(path)
        }
        guard URLComponents(url: url, resolvingAgainstBaseURL: true)?.url != nil else {
            throw NetworkingError.invalidURL(baseURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(acceptableMediaType, forHTTPHeaderField: "Accept")
        urlRequest.timeoutInterval = 10.0

        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let body = try buildBody() {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = body
        }

        return urlRequest
    }

    func statusCodeCheck(urlResponse: HTTPURLResponse) throws {
        guard 200..<300 ~= urlResponse.statusCode else {
            throw NetworkingError.invalidStatusCode(urlResponse.statusCode)
        }
    }
}
