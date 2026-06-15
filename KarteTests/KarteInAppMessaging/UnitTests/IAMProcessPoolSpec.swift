//
//  Copyright 2022 PLAID, Inc.
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
@testable import KarteInAppMessaging

@MainActor
class IAMProcessPoolSpec: XCTestCase {
    func testCanCreateProcessReturnsFalseWhenSceneIdExistsInPool() {
        let pool = IAMProcessPool()
        let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
        pool.storeProcess(process)
        XCTAssertFalse(pool.processes.isEmpty, "pool should not be empty after store")
        XCTAssertFalse(pool.canCreateProcess(sceneId: SceneId("DEFAULT")), "should not create process when sceneId already exists")
    }

    func testCanCreateProcessReturnsFalseWhenPoolIsEmpty() {
        let pool = IAMProcessPool()
        XCTAssertTrue(pool.processes.isEmpty, "pool should be empty initially")
        XCTAssertFalse(pool.canCreateProcess(sceneId: SceneId("DEFAULT")), "should not create process when pool is empty")
    }

    func testRetrieveProcessBySceneIdReturnsProcessWhenMatched() {
        let pool = IAMProcessPool()
        let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
        pool.storeProcess(process)
        let actual = pool.retrieveProcess(sceneId: SceneId("DEFAULT"))
        XCTAssertNotNil(actual, "should retrieve process with matching sceneId")
        XCTAssertEqual(actual?.sceneId.identifier, "DEFAULT", "sceneId identifier should match")
    }

    func testRetrieveProcessBySceneIdReturnsNilWhenNotMatched() {
        let pool = IAMProcessPool()
        let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
        process.sceneId.identifier = "NOT DEFAULT"
        pool.storeProcess(process)
        let actual = pool.retrieveProcess(sceneId: SceneId("DEFAULT"))
        XCTAssertNil(actual, "should return nil when sceneId does not match")
    }

    func testRetrieveProcessByViewReturnsProcessWhenMatched() {
        let pool = IAMProcessPool()
        let view = UIView()
        let process = IAMProcess(view: view, configuration: IAMProcessConfiguration(app: KarteApp.shared))
        pool.storeProcess(process)
        let actual = pool.retrieveProcess(view: view)
        XCTAssertNotNil(actual, "should retrieve process with matching view")
        XCTAssertEqual(actual?.sceneId.identifier, "DEFAULT", "sceneId identifier should match")
    }

    func testRetrieveProcessByViewReturnsNilWhenNotMatched() {
        let pool = IAMProcessPool()
        let view = UIView()
        let process = IAMProcess(view: view, configuration: IAMProcessConfiguration(app: KarteApp.shared))
        process.sceneId.identifier = "NOT DEFAULT"
        pool.storeProcess(process)
        let actual = pool.retrieveProcess(view: view)
        XCTAssertNil(actual, "should return nil when sceneId does not match")
    }

    func testStoreProcessAddsProcessToPool() {
        let pool = IAMProcessPool()
        let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
        XCTAssertTrue(pool.processes.isEmpty, "pool should be empty before store")
        pool.storeProcess(process)
        XCTAssertFalse(pool.processes.isEmpty, "pool should not be empty after store")
    }

    func testRemoveProcessRemovesProcessFromPool() {
        let pool = IAMProcessPool()
        let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
        pool.storeProcess(process)
        XCTAssertFalse(pool.processes.isEmpty, "pool should not be empty after store")
        pool.removeProcess(sceneId: SceneId("DEFAULT"))
        XCTAssertTrue(pool.processes.isEmpty, "pool should be empty after remove")
    }
}
