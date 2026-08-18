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
@testable import KarteVisualTracking

class DefinitionLoadSpec: XCTestCase {

    func testDefinitionLoadRequestAndDefinitions() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let builder = StubBuilder(spec: Self.self, resource: .vt2).build()
        let eventName = EventName("foo")
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Tracker.track(event: Event(eventName: eventName))

        let request = module.wait().request(eventName)

        guard let headers = request?.allHTTPHeaderFields else {
            XCTFail("request should not be nil")
            return
        }
        XCTAssertTrue(headers.keys.contains("X-KARTE-Auto-Track-OS"), "has X-KARTE-Auto-Track-OS header")
        XCTAssertEqual(headers["X-KARTE-Auto-Track-OS"], "iOS", "X-KARTE-Auto-Track-OS header value is iOS")
        XCTAssertTrue(headers.keys.contains("X-KARTE-Auto-Track-If-Modified-Since"), "has X-KARTE-Auto-Track-If-Modified-Since header")
        XCTAssertEqual(headers["X-KARTE-Auto-Track-If-Modified-Since"], "0", "X-KARTE-Auto-Track-If-Modified-Since header value is 0")

        guard let definitions = VisualTrackingManager.shared.tracker?.definitions else {
            XCTFail("definitions should not be nil")
            return
        }
        XCTAssertEqual(definitions.definitions?.first?.triggers.count, 2, "only has valid trigger")
        if case let .and(c) = definitions.definitions?.first?.triggers.first?.condition {
            XCTAssertEqual(c.count, 2, "only has valid conditions")
        } else {
            XCTFail("condition should be .and")
        }
    }
}
