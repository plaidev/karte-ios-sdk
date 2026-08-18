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

@MainActor
class DefinitionMatchSpec: XCTestCase {

    func testMatchDefinitionAndTrack() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }

        let builder1 = StubBuilder(spec: Self.self, resource: .vt1).build()
        let module1 = StubActionModule(metadata: name, builder: builder1)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        Tracker.track(event: Event(.view(viewName: "dummy", title: "dummy", values: [:])))

        module1.wait()

        let builder2 = StubBuilder(spec: Self.self, resource: .empty).build()
        let module2 = StubActionModule(metadata: name, builder: builder2)

        let action = UIKitAction("dummy", view: UIButton(), viewController: nil, targetText: "購入")
        VisualTrackingManager.shared.dispatch(action: action)

        guard let event = module2.wait().event(.view) else {
            XCTFail("view event should not be nil")
            return
        }
        XCTAssertEqual(event.eventName, .view, "eventName is view")
        XCTAssertEqual(event.values.integer(forKeyPath: "_system.auto_track"), 1, "values._system.auto_track")
        XCTAssertEqual(event.values.string(forKey: "foo"), "bar", "values.foo is bar")
    }
}
