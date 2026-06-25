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
import KarteUtilities
@testable import KarteCore
@testable import KarteRemoteNotification

class UserInfoBuilder {
    var isPushNotificationEnabled = true
    var isMassPushNotificationEnabled = false
    var campaignId = "dummy_campaign_id"
    var shortenId = "dummy_shorten_id"
    var url: String? = "https://karte.io"

    func setPushNotification(_ isEnabled: Bool) -> UserInfoBuilder {
        self.isPushNotificationEnabled = isEnabled
        self.isMassPushNotificationEnabled = !isEnabled
        return self
    }

    func setMassPushNotification(_ isEnabled: Bool) -> UserInfoBuilder {
        self.isPushNotificationEnabled = !isEnabled
        self.isMassPushNotificationEnabled = isEnabled
        return self
    }

    func setCampaignId(_ campaignId: String) -> UserInfoBuilder {
        self.campaignId = campaignId
        return self
    }

    func setShortenId(_ shortenId: String) -> UserInfoBuilder {
        self.shortenId = shortenId
        return self
    }

    func setURL(_ url: String?) -> UserInfoBuilder {
        self.url = url
        return self
    }

    func build() -> [AnyHashable: Any] {
        var userInfo: [AnyHashable: Any] = [
            "krt_campaign_id": campaignId,
            "krt_shorten_id": shortenId,
            "krt_event_values": "{\"v\": true}",
        ]
        if isPushNotificationEnabled {
            userInfo["krt_push_notification"] = true
        }
        if isMassPushNotificationEnabled {
            userInfo["krt_mass_push_notification"] = true
        }
        if let url = url {
            userInfo["krt_attributes"] = "{\"url\":\"\(url)\"}"
        } else {
            userInfo["krt_attributes"] = "{}"
        }
        return userInfo
    }
}

// MARK: - Track Tests

class MeasurementSpec: XCTestCase {
    private var builder: Builder!

    override func setUp() {
        super.setUp()

        builder = StubBuilder(spec: Self.self, resource: .empty).build()

        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
    }

    func testTrackDefaultPushNotification() throws {
        let module = StubActionModule(metadata: name, builder: builder)

        let userInfo = UserInfoBuilder().build()
        let notification = RemoteNotification(userInfo: userInfo)!
        notification.track()

        guard let event = module.wait().event(.messageClick) else {
            XCTFail("event should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .messageClick, "event name is message_click")
        XCTAssertEqual(event.values.string(forKeyPath: "message.campaign_id"), "dummy_campaign_id", "campaign_id is dummy_campaign_id")
        XCTAssertEqual(event.values.string(forKeyPath: "message.shorten_id"), "dummy_shorten_id", "shorten_id is dummy_shorten_id")
        let v = try XCTUnwrap(event.values.bool(forKey: "v"), "v should not be nil")
        XCTAssertTrue(v, "v is true")
    }

    func testTrackMassPushNotification() throws {
        let module = StubActionModule(metadata: name, builder: builder)

        let userInfo = UserInfoBuilder().setMassPushNotification(true).build()
        let notification = RemoteNotification(userInfo: userInfo)!
        notification.track()

        guard let event = module.wait().event(.massPushClick) else {
            XCTFail("event should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .massPushClick, "event name is mass_push_click")
        XCTAssertNil(event.values.string(forKeyPath: "message.campaign_id"), "campaign_id is nil")
        XCTAssertNil(event.values.string(forKeyPath: "message.shorten_id"), "shorten_id is nil")
        let v = try XCTUnwrap(event.values.bool(forKey: "v"), "v should not be nil")
        XCTAssertTrue(v, "v is true")
    }
}

// MARK: - URL Tests

class MeasurementURLSpec: XCTestCase {
    func testUrlIsValid() {
        let userInfo = UserInfoBuilder().build()
        let notification = RemoteNotification(userInfo: userInfo)!

        XCTAssertEqual(notification.url?.absoluteString, "https://karte.io", "url is https://karte.io")
    }

    func testUrlIsNotValid() {
        let userInfo = UserInfoBuilder().setURL("NOT URL!!!").build()
        let notification = RemoteNotification(userInfo: userInfo)!

        XCTAssertNil(notification.url, "url is nil for invalid url")
    }

    func testUrlIsNotContained() {
        let userInfo = UserInfoBuilder().setURL(nil).build()
        let notification = RemoteNotification(userInfo: userInfo)!

        XCTAssertNil(notification.url, "url is nil when not contained")
    }
}
