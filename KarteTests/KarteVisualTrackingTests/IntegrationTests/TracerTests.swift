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
@testable import KarteVisualTracking

class VisualTrackDelegate: VisualTrackingDelegate {
    var countOfCall = 0
    var isPaired = false
    func visualTrackingDevicePairingStatusUpdated(_ visualTracking: VisualTracking, isPaired: Bool) {
        countOfCall += 1
        self.isPaired = isPaired
    }
}

@MainActor
class TracerTests: XCTestCase {
    let idfa = IDFA()
    let visualTrackDelegate = VisualTrackDelegate()

    override func setUp() {
        Resolver.registerMockServices()
        KarteApp.shared.teardown()
    }

    override func tearDown() {
        KarteApp.shared.teardown()
        VisualTracking.shared.delegate = nil
    }

    func testPairingAndTrace() throws {
        let exp = expectation(description: "Wait for pairing and trace tests")

        func buildContent() -> Builder {
            let data = Data("OK".utf8)
            return http(200, headers: nil, download: .content(data))
        }

        nonisolated(unsafe) var pairingRequest: URLRequest?
        nonisolated(unsafe) var pairingBody: PairingRequestBody?
        let pairingStub = stub(uri("/v0/native/auto-track/pairing-start")) { request in
            pairingRequest = request
            pairingBody = request.pairingRequestBody()
            return buildContent()(request)
        }

        var pass = false
        nonisolated(unsafe) var heartbeatRequest: URLRequest?
        nonisolated(unsafe) var heartbeatBody: PairingHeartbeatRequestBody?
        let heartbeatStub = stub(uri("/v0/native/auto-track/pairing-heartbeat")) { request in
            if pass {
                return buildContent()(request)
            }
            pass = true

            heartbeatRequest = request
            heartbeatBody = request.pairingHeartbeatRequestBody()

            DispatchQueue.main.async {
                let action = UIKitAction("dummy", view: UIButton(), viewController: nil, targetText: "購入")
                VisualTrackingManager.shared.dispatch(action: action)
            }

            return buildContent()(request)
        }

        nonisolated(unsafe) var traceRequest: URLRequest?
        let traceStub = stub(uri("/v0/native/auto-track/trace")) { request in
            traceRequest = request
            exp.fulfill()
            return buildContent()(request)
        }

        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
            configuration.idfaDelegate = idfa
        }
        
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        VisualTracking.shared.delegate = visualTrackDelegate
        
        XCTAssertFalse(VisualTracking.shared.isPaired, "isPaired should be false before pairing")
        XCTAssertEqual(visualTrackDelegate.countOfCall, 0, "countOfCall should be 0 before pairing")
        XCTAssertFalse(visualTrackDelegate.isPaired, "delegate isPaired should be false before pairing")
        
        let pairingURL = try XCTUnwrap(URL(string: "app://_krtp/dummy_account_id"))
        let res = KarteApp.shared.application(UIApplication.shared, open: pairingURL)
        XCTAssertTrue(res, "application(_:open:) should return true for pairing URL")

        waitForExpectations(timeout: 10)

        // pairing-start リクエストの検証
        let pairingReq = try XCTUnwrap(pairingRequest, "pairing-start request should have been received")
        let pairing = try XCTUnwrap(pairingBody, "pairingRequestBody should not be nil")
        XCTAssertEqual(pairingReq.allHTTPHeaderFields?["X-KARTE-App-Key"], APP_KEY, "X-KARTE-App-Key")
        XCTAssertEqual(pairingReq.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"], "dummy_account_id", "X-KARTE-Auto-Track-Account-Id")
        XCTAssertEqual(pairing.os, "iOS", "os")
        XCTAssertEqual(pairing.visitorId, "dummy_visitor_id", "visitor_id")
        XCTAssertEqual(pairing.appInfo.versionName, "1.0.0", "app_info.version_name")
        XCTAssertEqual(pairing.appInfo.versionCode, "1", "app_info.version_code")
        XCTAssertEqual(pairing.appInfo.karteSdkVersion, "1.0.0", "app_info.karte_sdk_version")
        XCTAssertEqual(pairing.appInfo.systemInfo.os, "iOS", "app_info.system_info.os")
        XCTAssertEqual(pairing.appInfo.systemInfo.osVersion, "13.0", "app_info.system_info.os_version")
        XCTAssertEqual(pairing.appInfo.systemInfo.device, "iPhone", "app_info.system_info.device")
        XCTAssertEqual(pairing.appInfo.systemInfo.model, "iPhone10,3", "app_info.system_info.model")
        XCTAssertEqual(pairing.appInfo.systemInfo.bundleId, "io.karte", "app_info.system_info.bundle_id")
        XCTAssertEqual(pairing.appInfo.systemInfo.language, "ja-JP", "app_info.system_info.language")
        XCTAssertEqual(pairing.appInfo.systemInfo.idfv, "dummy_idfv", "app_info.system_info.idfv")
        XCTAssertEqual(pairing.appInfo.systemInfo.idfa, "dummy_idfa", "app_info.system_info.idfa")

        // pairing-heartbeat リクエスト（初回）の検証
        let heartbeatReq = try XCTUnwrap(heartbeatRequest, "pairing-heartbeat request should have been received")
        let heartbeat = try XCTUnwrap(heartbeatBody, "pairingHeartbeatRequestBody should not be nil")
        XCTAssertEqual(heartbeatReq.allHTTPHeaderFields?["X-KARTE-App-Key"], APP_KEY, "X-KARTE-App-Key")
        XCTAssertEqual(heartbeatReq.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"], "dummy_account_id", "X-KARTE-Auto-Track-Account-Id")
        XCTAssertEqual(heartbeat.os, "iOS", "os")
        XCTAssertEqual(heartbeat.visitorId, "dummy_visitor_id", "visitor_id")

        // trace リクエストの検証
        let traceReq = try XCTUnwrap(traceRequest, "trace request should have been received")
        XCTAssertEqual(traceReq.allHTTPHeaderFields?["X-KARTE-App-Key"], APP_KEY, "X-KARTE-App-Key")
        XCTAssertEqual(traceReq.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"], "dummy_account_id", "X-KARTE-Auto-Track-Account-Id")

        // ペアリング状態の検証
        XCTAssertTrue(VisualTracking.shared.isPaired, "isPaired should be true after pairing")
        XCTAssertEqual(visualTrackDelegate.countOfCall, 1, "countOfCall should be 1 after pairing")
        XCTAssertTrue(visualTrackDelegate.isPaired, "delegate isPaired should be true after pairing")

        removeStub(pairingStub)
        removeStub(heartbeatStub)
        removeStub(traceStub)
    }
}
