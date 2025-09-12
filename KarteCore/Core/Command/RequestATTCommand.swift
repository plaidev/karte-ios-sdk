//
//  Copyright 2024 PLAID, Inc.
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

import AppTrackingTransparency

internal struct RequestATTCommand: Command {
    func validate(_ url: URL) -> Bool {
        url.host == "request-att"
    }

    func execute() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            Logger.warn(tag: .core, message: "ATT is already determined, status = \(ATTrackingManager.trackingAuthorizationStatus)")
            return
        }

        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                Logger.info(tag: .core, message: "ATT status is authorized")
            case .denied:
                Logger.info(tag: .core, message: "ATT status is denied")
            case .notDetermined:
                Logger.info(tag: .core, message: "ATT status is notDetermined")
            case .restricted:
                Logger.info(tag: .core, message: "ATT status is restricted")
            @unknown default:
                Logger.warn(tag: .core, message: "ATT status is unknown: \(status)")
            }
        }
    }
}
