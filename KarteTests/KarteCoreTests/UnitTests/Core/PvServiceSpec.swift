//
//  Copyright 2026 PLAID, Inc.
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

class PvServiceSpec: XCTestCase {

    private let sceneId = SceneId("dummy-scene-id")
    private var pvIdGeneratorMock: PvIdGeneratorMock!
    private var service: PvService!
    private var recordingModule: RecordingActionModule!

    override func setUp() {
        super.setUp()
        pvIdGeneratorMock = PvIdGeneratorMock(ids: [
            "original-pv-id",
            "renewed-pv-id-1",
            "renewed-pv-id-2",
            "renewed-pv-id-3"
        ])
        let resolver = Resolver(parent: Resolver.mock)
        resolver.register(name: "pv_service.generator") {
            self.pvIdGeneratorMock as any IdGenerator
        }
        resolver.register(name: "pv_service.pv_id_bucket") { PvIdBucket() }
        resolver.register(name: "pv_service.original_pv_id_bucket") { PvIdBucket() }
        Resolver.root = resolver

        service = PvService()
        recordingModule = RecordingActionModule()
        KarteApp.shared.register(module: .action(recordingModule))
    }

    override func tearDown() {
        KarteApp.shared.unregister(module: .action(recordingModule))
        Resolver.root = Resolver.mock
        super.tearDown()
    }

    func testChangePv_firstView_renewsPvIdWithoutModuleReset() {
        XCTAssertEqual(
            service.pvId(forSceneId: sceneId).identifier,
            "original-pv-id",
            "initial pvId resolves to original"
        )

        service.changePv(sceneId)

        XCTAssertEqual(
            service.pvId(forSceneId: sceneId).identifier,
            "renewed-pv-id-1",
            "pvId is renewed"
        )
        XCTAssertEqual(
            service.originalPvId(forSceneId: sceneId).identifier,
            "original-pv-id",
            "originalPvId is unchanged"
        )
        XCTAssertEqual(recordingModule.resetCallCount, 0, "module reset is not called on first view")
    }

    func testChangePv_secondView_renewsPvIdAndResetsModules() {
        service.changePv(sceneId)
        service.changePv(sceneId)

        XCTAssertEqual(recordingModule.resetCallCount, 1, "module reset is called on second view")
        XCTAssertEqual(recordingModule.resetSceneIds, [sceneId])
        XCTAssertEqual(
            service.pvId(forSceneId: sceneId).identifier,
            "renewed-pv-id-2",
            "pvId is renewed again"
        )
    }
}

private final class RecordingActionModule: ActionModule {
    private(set) var resetCallCount = 0
    private(set) var resetSceneIds: [SceneId] = []

    var name: String { "RecordingActionModule" }
    var queue: DispatchQueue? { nil }

    func reset(sceneId: SceneId) {
        resetCallCount += 1
        resetSceneIds.append(sceneId)
    }

    func resetAll() {
    }
}
