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

/// Track API のリクエスト情報を保持する構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct TrackRequest: Request {
    public typealias Response = TrackResponse

    /// ビジターID
    public let visitorId: String
    /// シーンID
    public let sceneId: SceneId
    /// ページビューID
    public let pvId: PvId
    /// オリジナルページビューID
    public let originalPvId: PvId

    let requestId: String
    var appKey: String
    var appInfo: AppInfo
    var configuration: Configuration
    let commands: [TrackingCommand]
    let isRetry: Bool

    public var baseURL: URL {
        configuration.baseURL
    }

    public var path: String {
        "/v0/native/track"
    }

    public var method: HTTPMethod {
        .post
    }

    // swiftlint:disable:next discouraged_optional_collection
    public var queryParameters: [String: Any]? {
        nil
    }

    public var bodyParameters: BodyParameters? {
        let events = commands.map { command -> Event in
            var event = command.event
            event.mergeAdditionalParameter(date: command.date, isRetry: command.isRetry)
            return event
        }
        return TrackBodyParameters(
            appInfo: appInfo,
            events: events,
            keys: TrackBodyParameters.Keys(visitorId: visitorId, pvId: pvId, originalPvId: originalPvId)
        )
    }

    public var headerFields: [String: String] {
        [
            "X-KARTE-App-Key": appKey
        ]
    }

    public var dataParser: DataParser {
        RawDataParser()
    }

    /// 構造体の初期化をします。
    ///
    /// - Parameters:
    ///   - app: `KarteApp` インスタンス
    ///   - commands: トラッキングコマンド配列
    init?(app: KarteApp, commands: [TrackingCommand]) {
        guard let command = commands.first, let appInfo = app.appInfo else {
            return nil
        }

        self.visitorId = command.visitorId
        self.sceneId = command.scene.sceneId
        self.pvId = command.scene.pvId
        self.originalPvId = command.scene.originalPvId

        self.requestId = UUID().uuidString
        self.appKey = app.appKey
        self.appInfo = appInfo
        self.configuration = app.configuration
        self.commands = commands
        self.isRetry = command.isRetry
    }

    public func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 10.0

        if urlRequest.httpBody.map({ isGzipped($0) }) ?? false {
            urlRequest.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        }

        urlRequest = try KarteApp.shared.modules.reduce(urlRequest) { urlRequest, module -> URLRequest in
            if case let .track(module) = module {
                return try module.intercept(urlRequest: urlRequest)
            }
            return urlRequest
        }
        return urlRequest
    }

    public func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        let statusCode = urlResponse.statusCode
        if 200..<300 ~= statusCode {
            Logger.verbose(tag: .track, message: "The server returned a normal response: \(statusCode)")
        } else if 400..<500 ~= statusCode {
            Logger.warn(tag: .track, message: "The server returned an error response: \(statusCode)")
        } else if statusCode == 503 {
            Logger.warn(tag: .track, message: "Success to send request but service delivery is stopping: \(statusCode)")
        } else {
            Logger.error(tag: .track, message: "The server returned an error response: \(statusCode)")
            throw TrackError.serverErrorOccurred
        }
        return object
    }

    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> TrackResponse {
        guard let data = object as? Data else {
            throw TrackError.emptyResponse
        }
        return try createJSONDecoder().decode(TrackResponse.self, from: data)
    }

    /// リクエストに指定されたイベントが含まれているかチェックする。
    ///
    /// - Parameter eventName: イベント名
    /// - Returns: 指定されたイベント名が含まれる場合は `true` を返し、含まれない場合は `false` を返します。
    public func contains(eventName: EventName) -> Bool {
        commands.contains { command -> Bool in
            let ret = command.event.eventName == eventName
            return ret
        }
    }
}
