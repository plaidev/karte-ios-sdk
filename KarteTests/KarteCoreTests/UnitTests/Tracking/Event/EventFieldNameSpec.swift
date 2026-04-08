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

import XCTest
@testable import KarteCore

class EventFieldNameSpec: XCTestCase {

    func testEventFieldNameRawValues() {
        XCTAssertEqual(EventFieldName.campaignId.rawValue, "campaign_id", "campaignId")
        XCTAssertEqual(EventFieldName.shortenId.rawValue, "shorten_id", "shortenId")
        XCTAssertEqual(EventFieldName.fcmToken.rawValue, "fcm_token", "fcmToken")
        XCTAssertEqual(EventFieldName.subscribe.rawValue, "subscribe", "subscribe")
        XCTAssertEqual(EventFieldName.massPushId.rawValue, "mass_push_id", "massPushId")
        XCTAssertEqual(EventFieldName.userId.rawValue, "user_id", "userId")
        XCTAssertEqual(EventFieldName.taskId.rawValue, "task_id", "taskId")
        XCTAssertEqual(EventFieldName.scheduleId.rawValue, "schedule_id", "scheduleId")
        XCTAssertEqual(EventFieldName.sourceUserId.rawValue, "source_user_id", "sourceUserId")
        XCTAssertEqual(EventFieldName.target.rawValue, "target", "target")
        XCTAssertEqual(EventFieldName.newVisitorId.rawValue, "new_visitor_id", "newVisitorId")
        XCTAssertEqual(EventFieldName.oldVisitorId.rawValue, "old_visitor_id", "oldVisitorId")
        XCTAssertEqual(EventFieldName.viewId.rawValue, "view_id", "viewId")
        XCTAssertEqual(EventFieldName.viewName.rawValue, "view_name", "viewName")
        XCTAssertEqual(EventFieldName.title.rawValue, "title", "title")
        XCTAssertEqual(EventFieldName.previousVersionName.rawValue, "prev_version_name", "previousVersionName")
        XCTAssertEqual(EventFieldName.url.rawValue, "url", "url")
        XCTAssertEqual(EventFieldName.localEventDate.rawValue, "_local_event_date", "localEventDate")
        XCTAssertEqual(EventFieldName.retry.rawValue, "_retry", "retry")
    }

    func testEventFieldNameField() {
        XCTAssertEqual(field(.campaignId), "campaign_id", "field(.campaignId)")
    }
}
