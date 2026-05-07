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

class VersionServiceSpec: XCTestCase {

    private var versionRetriever: VersionRetrieverMock!

    override func setUp() {
        super.setUp()

        versionRetriever = VersionRetrieverMock()
        Resolver.root = Resolver.submock
        Resolver.root.register(name: "version_service.current_version_retriever") { [unowned self] in
            self.versionRetriever as VersionRetriever
        }
    }

    override func tearDown() {
        VersionService().clean()
        Resolver.root = Resolver.mock

        super.tearDown()
    }

    func testStateAfterInstallation() {
        let service = VersionService()

        XCTAssertEqual(service.installationStatus, .install, "installationStatus")
        XCTAssertEqual(service.currentVersion, "1.0.0", "currentVersion")
        XCTAssertNil(service.previousVersion, "previousVersion should be nil on first install")
    }

    func testStateAfterUpdate() {
        _ = VersionService()

        versionRetriever.ver = "1.0.1"
        let service = VersionService()

        XCTAssertEqual(service.installationStatus, .update, "installationStatus")
        XCTAssertEqual(service.currentVersion, "1.0.1", "currentVersion")
        XCTAssertEqual(service.previousVersion, "1.0.0", "previousVersion")
    }

    func testStateAfterNormalLaunch() {
        versionRetriever.ver = "1.0.1"
        _ = VersionService()

        let service = VersionService()

        XCTAssertEqual(service.installationStatus, .unknown, "installationStatus")
        XCTAssertEqual(service.currentVersion, "1.0.1", "currentVersion")
        XCTAssertEqual(service.previousVersion, "1.0.1", "previousVersion")
    }

    func testCleanDeletesStoredVersions() {
        versionRetriever.ver = "9.9.9"
        let service = VersionService()
        service.clean()

        let freshService = VersionService()
        XCTAssertNil(freshService.previousVersion, "previousVersion should be nil after clean")
    }

}
