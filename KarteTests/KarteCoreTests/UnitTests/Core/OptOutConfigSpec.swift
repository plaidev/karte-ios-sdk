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

class OptOutConfigSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: .optout)
    }

    override class func tearDown() {
        UserDefaults.standard.removeObject(forKey: .optout)
        super.tearDown()
    }

    // MARK: - config.isOptOut is true

    func testIsOptOutConfigIsTrueDefault() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = true })
        XCTAssertTrue(service.isOptOut, "isOptOut should be true by default")
    }

    func testIsOptOutConfigIsTrueCalledOptOut() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = true })
        service.optOut()
        XCTAssertTrue(service.isOptOut, "isOptOut should be true after optOut()")
    }

    func testIsOptOutConfigIsTrueCalledOptOutTemporarily() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = true })
        service.optOutTemporarily()
        XCTAssertTrue(service.isOptOut, "isOptOut should be true after optOutTemporarily()")
    }

    func testIsOptOutConfigIsTrueCalledOptIn() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = true })
        service.optIn()
        XCTAssertFalse(service.isOptOut, "isOptOut should be false after optIn()")
    }

    // MARK: - config.isOptOut is false

    func testIsOptOutConfigIsFalseDefault() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = false })
        XCTAssertFalse(service.isOptOut, "isOptOut should be false by default")
    }

    func testIsOptOutConfigIsFalseCalledOptOut() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = false })
        service.optOut()
        XCTAssertTrue(service.isOptOut, "isOptOut should be true after optOut()")
    }

    func testIsOptOutConfigIsFalseCalledOptOutTemporarily() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = false })
        service.optOutTemporarily()
        XCTAssertTrue(service.isOptOut, "isOptOut should be true after optOutTemporarily()")
    }

    func testIsOptOutConfigIsFalseCalledOptIn() {
        let service = OptOutService(configuration: Configuration { $0.isOptOut = false })
        service.optIn()
        XCTAssertFalse(service.isOptOut, "isOptOut should be false after optIn()")
    }
}
