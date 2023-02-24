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

    class func trackMessageSuppressed(message: TrackResponse.Response.Message, reason: String) {
        guard let campaignId = message.action.string(forKey: "campaign_id") else {
            return
        }
        guard let shortenId = message.action.string(forKey: "shorten_id") else {
            return
        }
        let values = [
            "reason": reason
        ]

        let event = Event(.message(type: .suppressed, campaignId: campaignId, shortenId: shortenId, values: values))
        Tracker.track(event: event)
    }

    class func track(view: UIView?, data: JsMessage.EventData) {
        let event = Event(
            eventName: data.eventName,
            values: data.values.mapValues { $0.rawValue },
            libraryName: InAppMessaging.name
        )
        Tracker(view: view).track(event: event)
    }
}
