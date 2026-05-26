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

import XCTest
@testable import KarteUtilities
@testable import KarteCore
@testable import KarteInAppMessaging

final class TrackMessageOpenSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        KarteApp.shared.register(module: .track(InAppMessaging()))
    }

    override func tearDown() {
        KarteApp.shared.unregister(module: .track(InAppMessaging()))
        super.tearDown()
    }

    private func makeConfiguration() -> KarteCore.Configuration {
        Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
    }

    private func makeBuilder() -> Builder {
        StubBuilder(spec: self, resource: .empty).build()
    }

    private func makeMessageOpenEvent(responseTimestamp: Date, libraryName: String? = nil) -> Event {
        Event(.message(type: .open, campaignId: "cid", shortenId: "sid", values: [
            "message": [
                "response_timestamp": iso8601DateTimeFormatter.string(from: responseTimestamp)
            ]
        ]), libraryName: libraryName)
    }

    func testInAppMessagingLibraryWithExpiredTimestamp() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.track(event: makeMessageOpenEvent(responseTimestamp: Date(timeIntervalSince1970: 0), libraryName: InAppMessaging.name))

        let event = module.wait().event(.messageOpen)

        XCTAssertNil(event, "expired message_open event should be filtered out for in_app_messaging library")
    }

    func testInAppMessagingLibraryWithCurrentTimestamp() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.track(event: makeMessageOpenEvent(responseTimestamp: Date(timeIntervalSince1970: 4_102_444_800), libraryName: InAppMessaging.name))

        let event = module.wait().event(.messageOpen)

        XCTAssertNotNil(event, "non-expired message_open event should be tracked for in_app_messaging library")
    }

    func testOtherLibraryWithExpiredTimestamp() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.track(event: makeMessageOpenEvent(responseTimestamp: Date(timeIntervalSince1970: 0)))

        let event = module.wait().event(.messageOpen)

        XCTAssertNotNil(event, "message_open event should be tracked regardless of expiration for other libraries")
    }

    func testOtherLibraryWithCurrentTimestamp() {
        let module = StubActionModule(metadata: name, builder: makeBuilder())

        KarteApp.setup(appKey: APP_KEY, configuration: makeConfiguration())
        Tracker.track(event: makeMessageOpenEvent(responseTimestamp: Date(timeIntervalSince1970: 4_102_444_800)))

        let event = module.wait().event(.messageOpen)

        XCTAssertNotNil(event, "message_open event should be tracked for other libraries")
    }
}
