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

class TrackDelegate: NSObject, TrackerDelegate {

    func intercept(_ event: Event) -> Event {
        var event = event
        event.merge(["foo": "bar"])
        return event
    }
}

class TrackDelegateSpec: XCTestCase {

    override func tearDown() {
        Tracker.setDelegate(nil)
        super.tearDown()
    }

    func testTrackDelegate() {
        let delegate = TrackDelegate()
        let builder: Builder = { request in
            let response = TrackResponse(success: 1, status: 200, response: EMPTY_RESPONSE, error: nil)
            let data = try! createJSONEncoder().encode(response)
            return jsonData(data)(request)
        }
        let module = StubActionModule(metadata: name, builder: builder)

        Tracker.setDelegate(delegate)
        KarteApp.setup(appKey: APP_KEY)

        guard let event = module.wait().event(.nativeAppOpen) else {
            XCTFail("event for native_app_open should not be nil")
            return
        }

        XCTAssertEqual(event.eventName, .nativeAppOpen, "event name is native_app_open")
        XCTAssertEqual(event.values.string(forKey: "foo"), "bar", "values.foo is bar")
    }
}
