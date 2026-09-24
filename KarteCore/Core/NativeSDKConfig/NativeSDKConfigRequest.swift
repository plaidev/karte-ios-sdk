//
//  Copyright 2026 PLAID, Inc.
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

typealias NativeSDKConfigFlags = [String: Bool]

struct NativeSDKConfigResponse {
    let flags: NativeSDKConfigFlags
    let ttl: TimeInterval
}

struct NativeSDKConfigRequest: Request {
    typealias Response = NativeSDKConfigResponse

    let baseURL: URL
    let appKey: String

    var method: HTTPMethod { .get }
    var path: String { "v0/native/sdk-config" }
    var headerFields: [String: String] { ["X-KARTE-App-Key": appKey] }
    var contentType: String { "application/json" }

    func buildBody() throws -> Data? { nil }

    func buildURLRequest() throws -> URLRequest {
        var urlRequest = try buildBaseURLRequest()
        guard let url = urlRequest.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkingError.invalidURL(baseURL)
        }
        components.queryItems = [URLQueryItem(name: "app_key", value: appKey)]
        urlRequest.url = components.url
        return urlRequest
    }

    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> NativeSDKConfigResponse {
        // NOTE: Boolean以外の値が含まれてもクラッシュしないようにしている。
        let raw = try JSONDecoder().decode([String: JSONValue].self, from: data)
        let flags = raw.compactMapValues { value -> Bool? in
            guard case .bool(let boolValue) = value else { return nil }
            return boolValue
        }
        return NativeSDKConfigResponse(flags: flags, ttl: urlResponse.cacheControlMaxAge())
    }
}

extension HTTPURLResponse {
    func cacheControlMaxAge() -> TimeInterval {
        guard let cacheControl = value(forHTTPHeaderField: "Cache-Control") else {
            return NativeSDKConfigCacheControl.fallbackTTL
        }

        let maxAgePrefix = "max-age="
        for directive in cacheControl.split(separator: ",") {
            let trimmed = directive.trimmingCharacters(in: .whitespaces)
            guard trimmed.lowercased().hasPrefix(maxAgePrefix) else {
                continue
            }
            let value = trimmed.dropFirst(maxAgePrefix.count)
            guard let seconds = Int(value) else {
                return NativeSDKConfigCacheControl.fallbackTTL
            }
            // NOTE: 想定外の値が入るのを防ぐために、60s〜3600sの範囲に切り詰める。
            return min(max(TimeInterval(seconds), 60), 3600)
        }

        return NativeSDKConfigCacheControl.fallbackTTL
    }
}

private enum NativeSDKConfigCacheControl {
    static let fallbackTTL: TimeInterval = 300
}
