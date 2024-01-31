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
import KarteUtilities

internal struct IAMProcessConfiguration {
    var app: KarteApp

    init(app: KarteApp) {
        self.app = app
    }

    func generateOverlayURL() -> URL? {
        guard let appInfo = app.appInfo else {
            Logger.error(tag: .inAppMessaging, message: "SDK is not initialized.")
            return nil
        }
        guard let appInfoData = try? createJSONEncoder().encode(appInfo) else {
            Logger.error(tag: .inAppMessaging, message: "Failed to construct JSON.")
            return nil
        }
        guard let appInfoString = String(data: appInfoData, encoding: .utf8) else {
            Logger.error(tag: .inAppMessaging, message: "Failed to convert string from JSON.")
            return nil
        }

        var components = URLComponents(string: "/v0/native/overlay")
        components?.queryItems = [
            URLQueryItem(name: "app_key", value: app.appKey),
            URLQueryItem(name: "_k_vid", value: app.visitorId),
            URLQueryItem(name: "_k_app_prof", value: appInfoString),
            URLQueryItem(name: "location", value: app.configuration.dataLocation)
        ]
        return components?.url(relativeTo: app.configuration.overlayBaseURL)
    }
}
