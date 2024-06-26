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

import Foundation
import AppTrackingTransparency

@available(iOS 14, *)
internal class ATTService {
    static func getATTStatusLabel(attStatus: ATTrackingManager.AuthorizationStatus) -> String {
        switch attStatus {
        case .authorized:
            "authorized"
        case .restricted:
            "restricted"
        case .notDetermined:
            "notDetermined"
        case .denied:
            "denied"
        @unknown default:
            "unknown"
        }
    }

    static func sendATTStatus(attStatus: ATTrackingManager.AuthorizationStatus) {
        let attStatusLabel = getATTStatusLabel(attStatus: attStatus)
        Tracker.track(event: Event(.attStatusUpdated(attStatus: attStatusLabel)))
    }
}
