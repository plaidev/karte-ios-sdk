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

public extension Tracker {
    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_open）を発火します。
    ///
    /// - Parameters:
    ///   - variables: 設定値の配列
    ///   - values: イベントに紐付けるカスタムオブジェクト
    class func trackOpen(variables: [Variable], values: [String: JSONConvertible] = [:]) {
        track(variables: variables, type: .open, values: values)
    }

    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_click）を発火します。
    ///
    /// - Parameters:
    ///   - variables: 設定値の配列
    ///   - values: イベントに紐付けるカスタムオブジェクト
    class func trackClick(variables: [Variable], values: [String: JSONConvertible] = [:]) {
        track(variables: variables, type: .click, values: values)
    }
}

internal extension Tracker {
    class func track(variables: [Variable], type: Event.MessageType, values: [String: JSONConvertible]) {
        var alreadySentCampaignIds = Set<String>()
        variables.forEach { variable in
            guard let campaignId = variable.campaignId, let shortenId = variable.shortenId else {
                return
            }
            guard !alreadySentCampaignIds.contains(campaignId) else {
                return
            }
            alreadySentCampaignIds.insert(campaignId)

            track(
                type: type,
                campaignId: campaignId,
                shortenId: shortenId,
                values: values,
                timestamp: variable.timestamp,
                eventHash: variable.eventHash
            )
        }
    }

    class func trackReady(messages: [VariableMessage]) {
        messages.forEach { message in
            guard let campaignId = message.campaign.campaignId, let shortenId = message.action.shortenId else {
                return
            }

            let noAction = message.action.noAction ?? false
            var values: [String: JSONConvertible] = [
                "no_action": noAction
            ]

            if let reason = message.action.reason, noAction {
                values["reason"] = reason
            }

            track(
                type: .ready,
                campaignId: campaignId,
                shortenId: shortenId,
                values: values,
                timestamp: message.action.responseTimestamp,
                eventHash: message.trigger.eventHashes
            )
        }
    }

    // swiftlint:disable:next function_parameter_count
    class func track(
        type: Event.MessageType,
        campaignId: String,
        shortenId: String,
        values: [String: JSONConvertible],
        timestamp: String?,
        eventHash: String?
    ) {
        var editableValues = values.mergingRecursive([
            "message": [
                "frequency_type": "access"
            ]
        ])

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
