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
@testable import KarteRemoteNotification

class RegisterPushCommandSpec: XCTestCase {

    func testRunWithInvalidValues_returnsFalse() {
        let invalidInputs = [
            "test:",
            "krt:",
            "krt://request-review",
            "krt://register-push",
            "krt-hSZM://register-push",
        ]

        let command = RegisterPushCommand()
        for input in invalidInputs {
            let url = URL(string: input)!
            XCTAssertFalse(command.run(url: url), "Expected false for invalid input: \(input)")
        }
    }

    func testValidateWithValidValues_returnsTrue() {
        let validInputs = [
            "krt-hSZMcVyjwg6Y7pdYMa4YPqmyQ77EpALw://register-push",
            "krt-HRTwj9QEZGJrTaTkADrtdxFTyuXUJVMh://register-push"
        ]

        let command = RegisterPushCommand()
        for input in validInputs {
            let url = URL(string: input)!
            XCTAssertTrue(command.validate(url), "Expected true for valid input: \(input)")
        }
    }
}
