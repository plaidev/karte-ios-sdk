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
import KarteCore
import KarteVariables

extension Tracker {
    /// IAFが依存する設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_open）を発火します。
    ///
    /// - Parameters:
    ///   - variable: IAF用設定値
    ///   - values: イベントに紐付けるカスタムオブジェクト
    class func trackOpen(variable: Variable, values: [String: JSONConvertible] = [:]) {
        guard let campaignId = variable.campaignId,
              let shortenId = variable.shortenId,
              let timestamp = variable.timestamp,
              let eventHash = variable.eventHash else {
            Logger.warn(tag: .inAppFrame, message: "Failed to send event: message_open, \(variable)\n\(values)")
            return
        }
        track(type: .open, campaignId: campaignId, shortenId: shortenId, values: values, timestamp: timestamp, eventHash: eventHash)
    }

    /// IAFが依存する設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_click）を発火します。
    ///
    /// - Parameters:
    ///   - variable: IAF用設定値
    ///   - values: イベントに紐付けるカスタムオブジェクト
    class func trackClick(variable: Variable, values: [String: JSONConvertible] = [:]) {
        guard let campaignId = variable.campaignId,
              let shortenId = variable.shortenId,
              let timestamp = variable.timestamp,
              let eventHash = variable.eventHash else {
            Logger.warn(tag: .inAppFrame, message: "Failed to send event: message_click, \(variable)\n\(values)")
            return
        }
        track(type: .click, campaignId: campaignId, shortenId: shortenId, values: values, timestamp: timestamp, eventHash: eventHash)
    }
}

extension Tracker {
    // swiftlint:disable:next function_parameter_count
    private class func track(
        type: Event.MessageType,
        campaignId: String,
        shortenId: String,
        values: [String: JSONConvertible],
        timestamp: String?,
        eventHash: String?
    ) {
        var editableValues = values
        if let timestamp = timestamp {
            editableValues.mergeRecursive([
                "message": [
                    "response_id": "\(timestamp)_\(shortenId)",
                    "response_timestamp": timestamp
                ]
            ])
        }
        if let eventHash = eventHash {
            editableValues.mergeRecursive([
                "message": [
                    "trigger": [
                        "event_hashes": eventHash
                    ]
                ]
            ])
        }

        let event = Event(.message(type: type, campaignId: campaignId, shortenId: shortenId, values: editableValues))
        Tracker.track(event: event)
    }
}
