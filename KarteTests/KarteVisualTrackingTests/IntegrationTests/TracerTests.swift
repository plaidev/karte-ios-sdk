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
import Mockingjay
import Nimble
import KarteUtilities
@testable import KarteCore
@testable import KarteVisualTracking

class TracerTests: XCTestCase {
    let idfa = IDFA()

    override func setUp() {
        Resolver.registerMockServices()
        KarteApp.shared.teardown()
    }

    override func tearDown() {
        KarteApp.shared.teardown()
    }

    func testPairingAndTrace() {
        let exp = expectation(description: "Wait for pairing and trace tests")

        func buildContent() -> (URLRequest) -> Response {
            let data = "OK".data(using: .utf8)!
            return http(200, headers: nil, download: .content(data))
        }

        let pairingStub = stub(uri("/v0/native/auto-track/pairing-start")) { (request) -> (Response) in
            let body = request.pairingRequestBodyParameters()!

            expect(request.allHTTPHeaderFields?["X-KARTE-App-Key"]).to(equal(APP_KEY))
            expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"]).to(equal("dummy_account_id"))
            expect(body.os).to(equal("iOS"))
            expect(body.visitorId).to(equal("dummy_visitor_id"))
            expect(body.appInfo.versionName).to(equal("1.0.0"))
            expect(body.appInfo.versionCode).to(equal("1"))
            expect(body.appInfo.karteSdkVersion).to(equal("1.0.0"))
            expect(body.appInfo.systemInfo.os).to(equal("iOS"))
            expect(body.appInfo.systemInfo.osVersion).to(equal("13.0"))
            expect(body.appInfo.systemInfo.device).to(equal("iPhone"))
            expect(body.appInfo.systemInfo.model).to(equal("iPhone10,3"))
            expect(body.appInfo.systemInfo.bundleId).to(equal("io.karte"))
            expect(body.appInfo.systemInfo.language).to(equal("ja-JP"))
            expect(body.appInfo.systemInfo.idfv).to(equal("dummy_idfv"))
            expect(body.appInfo.systemInfo.idfa).to(equal("dummy_idfa"))

            return buildContent()(request)
        }

        var pass = false
        let heartbeatStub = stub(uri("/v0/native/auto-track/pairing-heartbeat")) { (request) -> (Response) in
            let body = request.pairingHeartbeatRequestBodyParameters()!
            if pass {
                return buildContent()(request)
            }
            pass = true

            expect(request.allHTTPHeaderFields?["X-KARTE-App-Key"]).to(equal(APP_KEY))
            expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"]).to(equal("dummy_account_id"))
            expect(body.os).to(equal("iOS"))
            expect(body.visitorId).to(equal("dummy_visitor_id"))

            DispatchQueue.main.async {
                let action = Action("dummy", view: UIButton(), viewController: nil, targetText: "購入")
                VisualTrackingManager.shared.dispatch(action: action)
            }

            return buildContent()(request)
        }

        let traceStub = stub(uri("/v0/native/auto-track/trace")) { (request) -> (Response) in

            expect(request.allHTTPHeaderFields?["X-KARTE-App-Key"]).to(equal(APP_KEY))
            expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-Account-Id"]).to(equal("dummy_account_id"))

            exp.fulfill()

            return buildContent()(request)
        }

        let configuration = Configuration { (configuration) in
            configuration.isSendInitializationEventEnabled = false
            configuration.idfaDelegate = idfa
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let res = KarteApp.shared.application(UIApplication.shared, open: URL(string: "app://_krtp/dummy_account_id")!)
        expect(res).to(beTrue())

        waitForExpectations(timeout: 10) { [weak self] (error) in
            self?.removeStub(pairingStub)
            self?.removeStub(heartbeatStub)
            self?.removeStub(traceStub)
        }
    }
}
