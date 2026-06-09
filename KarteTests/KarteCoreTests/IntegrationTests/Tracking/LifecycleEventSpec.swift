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

class LifecycleEventSpec: XCTestCase {

    func testAfterLaunch() {
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY)

        XCTAssertNotNil(module.wait().event(.nativeAppOpen), "occurred native_app_open event")
    }

    func testAfterInstallation() {
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        KarteApp.setup(appKey: APP_KEY)

        XCTAssertNotNil(module.wait().event(.nativeAppInstall), "occurred native_app_install event")
    }

    func testAfterUpdate() {
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        Resolver.root = Resolver.submock
        Resolver.root.register(name: "version_service.current_version_retriever") {
            VersionRetrieverMock("1.0.0") as VersionRetriever
        }
        defer { Resolver.root = Resolver.mock }

        _ = VersionService()

        Resolver.root.register(name: "version_service.current_version_retriever") {
            VersionRetrieverMock("1.0.1") as VersionRetriever
        }

        KarteApp.setup(appKey: APP_KEY)

        guard let event = module.wait().event(.nativeAppUpdate) else {
            XCTFail("native_app_update event should not be nil")
            return
        }
        XCTAssertEqual(event.values.string(forKey: field(.previousVersionName)), "1.0.0", "values.prev_version_name")
    }

    func testNotAfterInstallationOrUpdate() {
        let builder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: builder)

        let versionRetriever = VersionRetrieverMock("1.0.0")

        Resolver.root = Resolver.submock
        Resolver.root.register(name: "version_service.current_version_retriever") {
            versionRetriever as VersionRetriever
        }
        defer { Resolver.root = Resolver.mock }

        _ = VersionService()

        KarteApp.setup(appKey: APP_KEY)

        let events = module.wait().events([.nativeAppInstall, .nativeAppUpdate])
        XCTAssertEqual(events.count, 0, "not occurred native_app_install and native_app_update event")
    }
}
