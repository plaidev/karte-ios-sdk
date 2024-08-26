//
//  Copyright 2023 PLAID, Inc.
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
import UIKit
import KarteCore

internal extension Tracker {

    class func trackMessageSuppressed(message: [String: JSONValue], reason: String) {
        guard let campaignId = message.string(forKeyPath: "action.campaign_id") else {
            return
        }
        guard let shortenId = message.string(forKeyPath: "action.shorten_id") else {
            return
        }
        if message.string(forKeyPath: "campaign.service_action_type") == "remote_config" {
            return
        }

        let values = [
            "reason": reason
        ]

        let event = Event(.message(type: .suppressed, campaignId: campaignId, shortenId: shortenId, values: values))
        Tracker.track(event: event)
    }

    class func track(view: UIView?, data: JsMessage.EventData) {
        var values = data.values.mapValues { $0.rawValue }

        let config = KarteApp.configuration.libraryConfigurations.first { $0 is InAppMessagingConfiguration } as? InAppMessagingConfiguration

        if let isEnabled = config?.isAutoScreenBoundaryEnabled {
            values["_is_auto_screen_boundary_enabled"] = isEnabled
        }

        let event = Event(
            eventName: data.eventName,
            values: values,
            libraryName: InAppMessaging.name
        )
        Tracker(view: view).track(event: event)
    }
}
