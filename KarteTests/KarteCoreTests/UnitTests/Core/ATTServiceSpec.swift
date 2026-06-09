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

import XCTest
@testable import KarteCore
import AppTrackingTransparency


class ATTServiceSpec: XCTestCase {

    func testGetATTStatusLabel() {
        XCTAssertEqual(ATTService.getATTStatusLabel(attStatus: .authorized), "authorized")
        XCTAssertEqual(ATTService.getATTStatusLabel(attStatus: .denied), "denied")
        XCTAssertEqual(ATTService.getATTStatusLabel(attStatus: .restricted), "restricted")
        XCTAssertEqual(ATTService.getATTStatusLabel(attStatus: .notDetermined), "notDetermined")
    }
}
