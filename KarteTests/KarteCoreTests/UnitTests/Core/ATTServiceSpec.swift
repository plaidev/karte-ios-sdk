//
//  Copyright 2024 PLAID, Inc.
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
@testable import KarteCore
import AppTrackingTransparency


class ATTServiceSpec: QuickSpec {

    override func spec() {
        describe("its run") {
            it("returns authorized label") {
                if #available(iOS 14, *) {
                    let result = ATTService.getATTStatusLabel(attStatus: ATTrackingManager.AuthorizationStatus.authorized)
                    expect(result).to(equal("authorized"))
                }
            }

            it("returns denied label") {
                if #available(iOS 14, *) {
                    let result = ATTService.getATTStatusLabel(attStatus: ATTrackingManager.AuthorizationStatus.denied)
                    expect(result).to(equal("denied"))
                }
            }

            it("returns restricted label") {
                if #available(iOS 14, *) {
                    let result = ATTService.getATTStatusLabel(attStatus: ATTrackingManager.AuthorizationStatus.restricted)
                    expect(result).to(equal("restricted"))
                }

            }

            it("returns notDetermined label") {
                if #available(iOS 14, *) {
                    let result = ATTService.getATTStatusLabel(attStatus: ATTrackingManager.AuthorizationStatus.notDetermined)
                        expect(result).to(equal("notDetermined"))
                }
            }
        }
    }
}