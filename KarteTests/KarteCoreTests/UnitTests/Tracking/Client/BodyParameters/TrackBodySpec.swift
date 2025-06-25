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

import Quick
import Nimble
@testable import KarteUtilities
@testable import KarteCore

func getBody() -> TrackBody {
    let appInfo = AppInfo()
    Resolver.registerAppInfo()
    return TrackBody(
        appInfo: appInfo,
        events: [Event(.foreground)],
        keys: TrackBody.Keys(
            visitorId: "dummy_vis_id",
            pvId: PvId(UUID().uuidString),
            originalPvId: PvId(UUID().uuidString)))
}

class TrackBodySpec: QuickSpec {
    
    override func spec() {
        describe("a track body parameters") {
            var body: TrackBody!
            
            beforeEach {
                body = getBody()
            }
            
            describe("its build") {
                it("is gzipped") {
                    let data = try! body.asData()
                    expect(data.isGzipped).to(beTrue())
                }
            }

            describe("its encoding") {
                it("uses correct coding keys") {
                    let encodedData = try! createJSONEncoder().encode(body)
                    let jsonObject = try! JSONSerialization.jsonObject(with: encodedData, options: []) as! [String: Any]
                    
                    expect(jsonObject["app_info"]).toNot(beNil())
                    expect(jsonObject["events"]).toNot(beNil())
                    expect(jsonObject["keys"]).toNot(beNil())
                }
            }
        }
    }
}
