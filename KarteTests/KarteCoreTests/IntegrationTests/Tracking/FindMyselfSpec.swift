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

class FindMyselfSpec: XCTestCase {

    func testFindMyself_whenHostIsNotKarteIo_returnsFalse() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let url = URL(string: "app://karte.com/find_myself")!
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let result = KarteApp.shared.application(UIApplication.shared, open: url)
        XCTAssertFalse(result, "host が karte.io でない場合は false を返す")
    }

    func testFindMyself_whenPathIsNotFindMyself_returnsFalse() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let url = URL(string: "app://karte.io/foo")!
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let result = KarteApp.shared.application(UIApplication.shared, open: url)
        XCTAssertFalse(result, "path が /find_myself でない場合は false を返す")
    }

    func testFindMyself_whenValidUrl() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let url = URL(string: "app://karte.io/find_myself?k=v")!
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        let result = KarteApp.shared.application(UIApplication.shared, open: url)
        guard let event = module.wait().event(.nativeFindMyself) else {
            XCTFail("native_find_myself イベントが取得できなかった")
            return
        }

        XCTAssertTrue(result, "有効な URL の場合は true を返す")
        XCTAssertEqual(event.eventName, .nativeFindMyself, "event name は native_find_myself")
        XCTAssertEqual(event.values.string(forKey: "k"), "v", "values.k は v")
    }
}
