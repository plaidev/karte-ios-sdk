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

internal struct PreviewURL {
    var app: KarteApp
    var opts: Opts
    var appInfo: AppInfo
    var krtActionPreview: String

    init(app: KarteApp, previewId: String, previewToken: String, appInfo: AppInfo) {
        self.app = app
        self.opts = Opts(previewId: previewId, previewToken: previewToken)
        self.krtActionPreview = previewToken
        self.appInfo = appInfo
    }

    func build() -> URL? {
        guard let appInfo = encodeJson(self.appInfo), let opts = encodeJson(self.opts) else {
            return nil
        }

        var component = URLComponents()
        component.path = "/v0/native/overlay"
        component.queryItems = [
            URLQueryItem(name: "app_key", value: app.appKey),
            URLQueryItem(name: "_k_vid", value: app.visitorId),
            URLQueryItem(name: "_k_app_prof", value: appInfo),
            URLQueryItem(name: "__karte_opts", value: opts),
            URLQueryItem(name: "__krtactionpreview", value: krtActionPreview)
        ]
        return component.url(relativeTo: app.configuration.baseURL)
    }

    private func encodeJson<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try? encoder.encode(value)
        return data.flatMap { String(data: $0, encoding: .utf8) }
    }
}

extension PreviewURL {
    struct Opts: Codable {
        var isPreview = true
        var previewId: String
        var previewToken: String
    }
}
