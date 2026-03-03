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

import Foundation
import XCTest
import KarteUtilities

final class HTTPStubProtocol: URLProtocol {
    struct StubResponse {
        let statusCode: Int
        let headers: [String: String]
        let data: Data
    }

    struct StubEntry: Identifiable {
        let id: UUID
        let group: String?
        let matcher: (URLRequest) -> Bool
        let builder: (URLRequest) -> StubResponse
    }

    private static let lock = NSLock()
    private static var stubs: [StubEntry] = []

    @discardableResult
    static func addStub(
        matcher: @escaping (URLRequest) -> Bool,
        builder: @escaping (URLRequest) -> StubResponse,
        group: String? = nil
    ) -> UUID {
        let entry = StubEntry(id: UUID(), group: group, matcher: matcher, builder: builder)
        lock.lock()
        defer { lock.unlock() }
        stubs.append(entry)
        return entry.id
    }

    static func removeStub(_ id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        stubs.removeAll { $0.id == id }
    }

    static func removeAllStubs() {
        lock.lock()
        defer { lock.unlock() }
        stubs.removeAll()
    }

    static func removeStubs(inGroup group: String) {
        lock.lock()
        defer { lock.unlock() }
        stubs.removeAll { $0.group == group }
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return stubs.contains { $0.matcher(request) }
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let matchingStub: StubEntry? = {
            HTTPStubProtocol.lock.lock()
            defer { HTTPStubProtocol.lock.unlock() }
            return HTTPStubProtocol.stubs.last { $0.matcher(request) }
        }()

        guard let stub = matchingStub else {
            let error = NSError(
                domain: "HTTPStubProtocol",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No stub found for request: \(request.url?.absoluteString ?? "nil")"]
            )
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = stub.builder(request)
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: response.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: response.headers
        )!

        client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - Convenience Matchers

extension HTTPStubProtocol {
    static func pathMatcher(_ path: String) -> (URLRequest) -> Bool {
        return { request in
            guard let url = request.url else { return false }
            return url.path == path
        }
    }

    static func urlMatcher(_ urlString: String) -> (URLRequest) -> Bool {
        return { request in
            guard let url = request.url else { return false }
            return url.absoluteString == urlString
        }
    }

    static func httpMatcher(_ method: String, path: String) -> (URLRequest) -> Bool {
        return { request in
            guard let url = request.url else { return false }
            return url.path == path && request.httpMethod?.uppercased() == method.uppercased()
        }
    }

    static func httpMatcher(_ method: String, url urlString: String) -> (URLRequest) -> Bool {
        return { request in
            guard let url = request.url else { return false }
            return url.absoluteString == urlString && request.httpMethod?.uppercased() == method.uppercased()
        }
    }
}

// MARK: - Convenience Response Builders

extension HTTPStubProtocol {
    static func jsonResponse(_ data: Data, status: Int = 200) -> (URLRequest) -> StubResponse {
        return { _ in
            StubResponse(
                statusCode: status,
                headers: ["Content-Type": "application/json"],
                data: data
            )
        }
    }

    static func httpResponse(status: Int = 200, headers: [String: String]? = nil, data: Data) -> (URLRequest) -> StubResponse {
        return { _ in
            StubResponse(
                statusCode: status,
                headers: headers ?? [:],
                data: data
            )
        }
    }
}

// MARK: - Mockingjay Compatibility

typealias Stub = UUID
typealias Builder = (URLRequest) -> HTTPStubProtocol.StubResponse

func uri(_ path: String) -> (URLRequest) -> Bool {
    return HTTPStubProtocol.pathMatcher(path)
}

func http(_ method: HTTPMethod, uri urlString: String) -> (URLRequest) -> Bool {
    return HTTPStubProtocol.httpMatcher(method.rawValue, url: urlString)
}

func http(_ method: HTTPMethod, path: String) -> (URLRequest) -> Bool {
    return HTTPStubProtocol.httpMatcher(method.rawValue, path: path)
}

func jsonData(_ data: Data, status: Int = 200) -> (URLRequest) -> HTTPStubProtocol.StubResponse {
    return HTTPStubProtocol.jsonResponse(data, status: status)
}

func http(_ statusCode: Int) -> (URLRequest) -> HTTPStubProtocol.StubResponse {
    return { _ in
        HTTPStubProtocol.StubResponse(statusCode: statusCode, headers: [:], data: Data())
    }
}

enum Download {
    case content(Data)
}

func http(_ statusCode: Int, headers: [String: String]?, download: Download) -> (URLRequest) -> HTTPStubProtocol.StubResponse {
    return { _ in
        let data: Data
        switch download {
        case .content(let d): data = d
        }
        return HTTPStubProtocol.StubResponse(statusCode: statusCode, headers: headers ?? [:], data: data)
    }
}

extension XCTestCase {
    @discardableResult
    func stub(_ matcher: @escaping (URLRequest) -> Bool,
              _ builder: @escaping (URLRequest) -> HTTPStubProtocol.StubResponse) -> Stub {
        return HTTPStubProtocol.addStub(matcher: matcher, builder: builder)
    }

    func removeStub(_ id: Stub) {
        HTTPStubProtocol.removeStub(id)
    }
}
