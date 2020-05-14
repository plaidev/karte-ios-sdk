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

func getBodyParameters() -> TrackBodyParameters {
    let appInfo = AppInfo()
    Resolver.registerAppInfo()
    return TrackBodyParameters(
        appInfo: appInfo,
        events: [Event(.foreground)],
        keys: TrackBodyParameters.Keys(
            visitorId: "dummy_vis_id",
            pvId: PvId(UUID().uuidString),
            originalPvId: PvId(UUID().uuidString)))
}

class TrackBodyParametersSpec: QuickSpec {
    
    override func spec() {
        describe("a track body parameters") {
            var bodyParameters: TrackBodyParameters!
            
            beforeEach {
                bodyParameters = getBodyParameters()
            }
            
            describe("its contentType") {
                it("is application/json") {
                    expect(bodyParameters.contentType).to(equal("application/json"))
                }
            }
            
            describe("its buildEntity") {
                it("is gzipped") {
                    let entity = try! bodyParameters.buildEntity()
                    if case let .data(d) = entity {
                        expect(d.isGzipped).to(beTrue())
                    }
                }
            }
        }
    }
}
