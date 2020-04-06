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

internal class ActionTracker {
    var definitions: AutoTrackDefinition?
    var app: KarteApp

    var definitionsLastModified: Int {
        definitions?.lastModified ?? 0
    }

    init(app: KarteApp) {
        self.app = app
    }

    func refreshDefinitions(response: TrackResponse.Response) {
        guard let autoTrackDefinition = response.autoTrackDefinition else {
            Logger.verbose(tag: .visualTracking, message: "VT definition is empty.")
            return
        }

        let definitions: AutoTrackDefinition
        do {
            definitions = try AutoTrackDefinition.from(dictionary: autoTrackDefinition)
        } catch {
            Logger.error(tag: .visualTracking, message: "Failed to convert data. \(error.localizedDescription)")
            return
        }

        if definitions.status == .modified && self.definitions?.lastModified != definitions.lastModified {
            Logger.info(tag: .visualTracking, message: "Update VT definition.")
            self.definitions = definitions
        } else {
            Logger.info(tag: .visualTracking, message: "VT definition has not modified.")
        }
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.addValue("iOS", forHTTPHeaderField: "X-KARTE-Auto-Track-OS")
        urlRequest.addValue(String(definitionsLastModified), forHTTPHeaderField: "X-KARTE-Auto-Track-If-Modified-Since")

        return urlRequest
    }

    deinit {
    }
}

extension ActionTracker {
    private func track(action: Action) {
        guard let definitions = definitions, let appInfo = app.appInfo else {
            Logger.verbose(tag: .visualTracking, message: "VT definition is nil.")
            return
        }

        let events = definitions.events(action: action, appInfo: appInfo)
        events.forEach { event in
            Tracker.track(event: event)
        }
    }
}

extension ActionTracker: ActionReceiver {
    func receive(action: Action) {
        track(action: action)
    }
}
