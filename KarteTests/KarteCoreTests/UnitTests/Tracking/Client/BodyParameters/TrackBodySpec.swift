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
@testable import KarteUtilities
@testable import KarteCore

private func makeBody() -> TrackBody {
    let appInfo = AppInfo()
    Resolver.registerAppInfo()
    return TrackBody(
        appInfo: appInfo,
        events: [Event(.foreground)],
        keys: TrackBody.Keys(
            visitorId: "dummy_vis_id",
            pvId: PvId("dummy_pv_id"),
            originalPvId: PvId("dummy_original_pv_id")))
}

class TrackBodySpec: XCTestCase {

    func testTrackBodyIsGzipped() {
        let body = makeBody()
        let data = try! body.asData()
        XCTAssertTrue(data.isGzipped, "is gzipped")
    }

    func testTrackBodyUsesCorrectCodingKeys() {
        let body = makeBody()
        let encodedData = try! createJSONEncoder().encode(body)
        let jsonObject = try! JSONSerialization.jsonObject(with: encodedData, options: []) as! [String: Any]

        XCTAssertNotNil(jsonObject["app_info"], "app_info key exists")
        XCTAssertNotNil(jsonObject["events"], "events key exists")
        XCTAssertNotNil(jsonObject["keys"], "keys key exists")
    }
}
