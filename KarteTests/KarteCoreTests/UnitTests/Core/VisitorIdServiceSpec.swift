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
import KarteUtilities
@testable import KarteCore

class VisitorIdServiceSpec: XCTestCase {

    var visitorIdGeneratorMock: VisitorIdGeneratorMock!

    override func setUp() {
        super.setUp()
        visitorIdGeneratorMock = VisitorIdGeneratorMock()
        Resolver.root = Resolver.submock
        Resolver.root.register(name: "visitor_id_service.generator") {
            self.visitorIdGeneratorMock as IdGenerator
        }
    }

    override func tearDown() {
        Resolver.root = Resolver.mock
        VisitorIdService().clean()
        super.tearDown()
    }

    func testInitialize() {
        let service = VisitorIdService()
        XCTAssertEqual(service.visitorId, "dummy_visitor_id", "initial visitorId")
        XCTAssertEqual(VisitorIdService().visitorId, "dummy_visitor_id", "stored visitorId")
    }

    func testRenew() {
        _ = VisitorIdService().visitorId
        visitorIdGeneratorMock.id = "renew_visitor_id"

        let service = VisitorIdService()
        service.renew()

        XCTAssertEqual(service.visitorId, "renew_visitor_id", "visitorId after renew")
        XCTAssertEqual(VisitorIdService().visitorId, "renew_visitor_id", "stored visitorId after renew")
    }

    func testCleanResetsVisitorId() {
        Resolver.root = Resolver.main

        let service = VisitorIdService()
        let visitorId = service.visitorId
        service.clean()

        XCTAssertNotEqual(VisitorIdService().visitorId, visitorId, "visitorId changes after clean")
    }
}
