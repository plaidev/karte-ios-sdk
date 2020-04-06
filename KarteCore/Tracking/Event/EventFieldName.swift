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

/// イベントのフィールド名を扱うための構造体です。
public struct EventFieldName {
    /// フィールド名
    public let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension EventFieldName {
    // swiftlint:disable operator_usage_whitespace
    /// message フィールド
    static let message      = EventFieldName("message")
    /// campaign_id フィールド
    static let campaignId   = EventFieldName("campaign_id")
    /// shorten_id フィールド
    static let shortenId    = EventFieldName("shorten_id")
    /// fcm_token フィールド
    static let fcmToken     = EventFieldName("fcm_token")
    /// subscribe フィールド
    static let subscribe    = EventFieldName("subscribe")
    /// mass_push_id フィールド
    static let massPushId   = EventFieldName("mass_push_id")
    /// user_id フィールド
    static let userId       = EventFieldName("user_id")
    /// task_id フィールド
    static let taskId       = EventFieldName("task_id")
    /// schedule_id フィールド
    static let scheduleId   = EventFieldName("schedule_id")
    /// source_user_id フィールド
    static let sourceUserId = EventFieldName("source_user_id")
    /// target フィールド
    static let target       = EventFieldName("target")
    /// new_visitor_id フィールド
    static let newVisitorId = EventFieldName("new_visitor_id")
    /// old_visitor_id フィールド
    static let oldVisitorId = EventFieldName("old_visitor_id")
    /// view_id フィールド
    static let viewId       = EventFieldName("view_id")
    /// view_name フィールド
    static let viewName     = EventFieldName("view_name")
    /// title フィールド
    static let title        = EventFieldName("title")
    // swiftlint:enable operator_usage_whitespace
}

extension EventFieldName {
    static let previousVersionName = EventFieldName("prev_version_name")
    static let localEventDate = EventFieldName("_local_event_date")
    static let retry = EventFieldName("_retry")
}

internal func field(_ name: EventFieldName) -> String {
    name.rawValue
}
