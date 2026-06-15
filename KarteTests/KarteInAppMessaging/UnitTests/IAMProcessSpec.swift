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

import UIKit
import XCTest
@testable import KarteCore
@testable import KarteInAppMessaging

@MainActor
class IAMProcessSpec: XCTestCase {
    override func setUp() {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
    }

    private func makeProcess() -> IAMProcess {
        let iamConfiguration = IAMProcessConfiguration(app: KarteApp.shared)
        return IAMProcess(view: UIView(), configuration: iamConfiguration)
    }

    func testInitialState() {
        let process = makeProcess()
        XCTAssertNotNil(process.sceneId, "sceneId should not be nil")
        XCTAssertTrue(process.isActivated, "isActivated should be true")
        XCTAssertFalse(process.isPresenting, "isPresenting should be false")
        XCTAssertFalse(process.isSuppressed, "isSuppressed should be false")
    }

    func testStateAfterTerminate() {
        let process = makeProcess()
        process.terminate()
        XCTAssertNotNil(process.sceneId, "sceneId should not be nil after terminate")
        XCTAssertFalse(process.isActivated, "isActivated should be false after terminate")
        XCTAssertFalse(process.isPresenting, "isPresenting should be false after terminate")
        XCTAssertFalse(process.isSuppressed, "isSuppressed should be false after terminate")
    }

    func testActivateWhenAlreadyActivated() {
        let process = makeProcess()
        process.activate()
        XCTAssertTrue(process.isActivated, "isActivated should remain true")
    }

    func testActivateAfterTerminate() {
        let process = makeProcess()
        process.terminate()
        XCTAssertFalse(process.isActivated, "isActivated should be false after terminate")
        process.activate()
        XCTAssertTrue(process.isActivated, "isActivated should be true after re-activate")
    }
}
