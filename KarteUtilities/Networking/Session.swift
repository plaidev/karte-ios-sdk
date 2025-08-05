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

public class Session {
    private let urlSession: URLSession = .shared
    public static let shared = Session()

    @discardableResult
    public class func send<R: Request>(
        _ request: R,
        handler: @escaping (Result<R.Response, NetworkingError>) -> Void = { _ in }
    ) -> URLSessionTask? {
        return shared.send(request, handler: handler)
    }

    func send<R: Request>(
        _ request: R,
        handler: @escaping (Result<R.Response, NetworkingError>) -> Void
    ) -> URLSessionTask? {
        let urlRequest: URLRequest

        do {
            urlRequest = try request.buildURLRequest()
        } catch {
            handler(.failure(NetworkingError.requestBuildFailed(error)))
            return nil
        }

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in

            if let error = error {
                handler(.failure(.requestFailed(error)))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                handler(.failure(.invalidResponse(response)))
                return
            }

            do {
                try request.statusCodeCheck(urlResponse: urlResponse)
            } catch {
                handler(.failure(.responseError(error)))
                return
            }

            guard let data = data else {
                handler(.failure(.noData))
                return
            }

            do {
                let response = try request.parse(data: data as Data, urlResponse: urlResponse)
                handler(.success(response))
            } catch {
                handler(.failure(.responseError(error)))
            }
        }
        task.resume()
        return task
    }
}
