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
import KarteCore
import KarteUtilities

protocol Caller {
    func callAsFunction<Request: BaseAPIRequest>(callee request: Request) async -> Request.Response?
    func intercept(data: Data, response: URLResponse) -> Data?
    func parseError(_ response: URLResponse, _ data: Data) -> (String, String)
}

extension Caller {
    func intercept(data: Data, response: URLResponse) -> Data? {
        guard let status = (response as? HTTPURLResponse)?.statusCode else {
            Logger.error(tag: .inbox, message: "Invalid response is returned")
            return nil
        }

        switch status {
        case 200..<300:
            Logger.verbose(tag: .inbox, message: "\(status): The server returned a normal response")
        case 400..<500:
            // swiftlint:disable:next no_fallthrough_only
            fallthrough
        default:
            let (path, error) = parseError(response, data)
            Logger.error(tag: .inbox, message: "\(status): The server returned an error on \(path): \(error)")
            return nil
        }
        return data
    }

    func parseError(_ response: URLResponse, _ data: Data) -> (String, String) {
        let path = (response as? HTTPURLResponse)?.url?.pathComponents.joined(separator: "/")
        return (String(describing: path), String(data: data, encoding: .utf8) ?? "")
    }
}

@available(iOS 15.0, *)
struct NativeAsyncCaller: Caller {
    func callAsFunction<Request: BaseAPIRequest>(callee request: Request) async -> Request.Response? {
        do {
            let req = request.asURLRequest()
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let res = intercept(data: data, response: response) else {
                return nil
            }
            let decoder = createJSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Request.Response.self, from: res)
        } catch {
            Logger.error(tag: .inbox, message: error.localizedDescription)
            return nil
        }
    }
}

struct FallbackAsyncCaller: Caller {
    func callAsFunction<Request: BaseAPIRequest>(callee request: Request) async -> Request.Response? {
        let req = request.asURLRequest()
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: req) { (data, response, error) in
                do {
                    guard let data = data, let response = response else {
                        if let status = (response as? HTTPURLResponse)?.statusCode {
                            throw ResponseError.unacceptableStatusCode(status)
                        } else {
                            throw ResponseError.nonHTTPURLResponse(response)
                        }
                    }

                    guard let res = intercept(data: data, response: response) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let decoder = createJSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(Request.Response.self, from: res)
                    continuation.resume(returning: decoded)
                } catch {
                    Logger.error(tag: .inbox, message: error.localizedDescription)
                    continuation.resume(returning: nil)
                }
            }.resume()
        }
    }
}
