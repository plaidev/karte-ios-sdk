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

internal enum Measurement {
    static func measure(userInfo: [AnyHashable: Any]) {
        if userInfo[RemoteNotificationKey.push.rawValue] != nil {
            mesureTargetPush(userInfo: userInfo)
        } else if userInfo[RemoteNotificationKey.massPush.rawValue] != nil {
            mesureMassPush(userInfo: userInfo)
        } else {
            Logger.verbose(tag: .notification, message: "This notification was not sent by KARTE.")
        }
    }

    private static func mesureTargetPush(userInfo: [AnyHashable: Any]) {
        guard let campaignId = userInfo[RemoteNotificationKey.campaignId.rawValue] as? String else {
            Logger.warn(tag: .notification, message: "Campaign id is not set.")
            return
        }
        guard let shortenId = userInfo[RemoteNotificationKey.shortenId.rawValue] as? String else {
            Logger.warn(tag: .notification, message: "Shorten id is not set.")
            return
        }
        guard let values = retrieveEventValues(userInfo: userInfo) else {
            return
        }

        let alias: Event.Alias = .message(type: .click, campaignId: campaignId, shortenId: shortenId, values: JSONConvertibleConverter.convert(values))
        let event = Event(alias)
        Tracker.track(event: event)
    }

    private static func mesureMassPush(userInfo: [AnyHashable: Any]) {
        guard let values = retrieveEventValues(userInfo: userInfo) else {
            return
        }

        let event = Event(
            eventName: .massPushClick,
            values: JSONConvertibleConverter.convert(values)
        )
        Tracker.track(event: event)
    }

    private static func retrieveEventValues(userInfo: [AnyHashable: Any]) -> [String: Any]? {
        guard let eventValues = userInfo[RemoteNotificationKey.eventValues.rawValue] as? String else {
            Logger.warn(tag: .notification, message: "Event value is not set.")
            return nil
        }
        guard let data = eventValues.data(using: .utf8) else {
            Logger.error(tag: .notification, message: "Failed to convert data.")
            return nil
        }
        guard let values = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            Logger.error(tag: .notification, message: "Failed to parse.")
            return nil
        }
        return values
    }
}
