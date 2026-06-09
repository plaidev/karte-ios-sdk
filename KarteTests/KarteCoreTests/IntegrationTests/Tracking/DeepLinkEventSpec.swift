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

class DeepLinkEventSpec: XCTestCase {

    func testDeepLinkEvent() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()

        let url = URL(string: "app://karte.com")!
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        let result = KarteApp.shared.application(UIApplication.shared, open: url)
        guard let event = module.wait().event(.deepLinkAppOpen) else {
            XCTFail("deep_link_app_open event should not be nil")
            return
        }

        XCTAssertFalse(result, "application(_:open:) should return false")
        XCTAssertEqual(event.eventName, .deepLinkAppOpen, "event name should be deep_link_app_open")
        XCTAssertEqual(event.values.string(forKey: "url"), "app://karte.com", "values.url should match the opened URL")
    }
}
