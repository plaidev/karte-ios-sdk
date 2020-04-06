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

import Foundation
import XCTest

func assertDateEqual(_ expression1: Date?, _ expression2: Date?, file: StaticString = #file, line: UInt = #line) {
    guard let expression1 = expression1, let expression2 = expression2 else {
        XCTFail("Date is not equal.", file: file, line: line)
        return
    }
    XCTAssertEqual(expression1.timeIntervalSince1970, expression2.timeIntervalSince1970, accuracy: 0.0001, file: file, line: line)
}
