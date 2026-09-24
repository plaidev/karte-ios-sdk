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

class KarteTestObserver: NSObject, XCTestObservation {

    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        // NOTE: 有効なNativeSDKConfigCacheが存在しない場合、_fetch_native_sdk_configイベントが送られてしまい、
        // テストと干渉するため、予めNativeSDKConfigCacheをセットする。
        let data = try! JSONEncoder().encode(NativeSDKConfigCache(flags: [:], fetchedAt: .distantFuture, ttl: 300))
        UserDefaults.standard.set(data, forKey: .nativeSDKConfig)

        // NOTE: KarteApp.setup()内でNativeSDKConfigService.startObserving()が呼ばれると
        // didBecomeActiveNotification発火時に/v0/native/sdk-configへのリクエストが発生するため、スタブする。
        HTTPStubProtocol.addStub(matcher: uri("/v0/native/sdk-config")) { _ in
            HTTPStubProtocol.StubResponse(
                statusCode: 200,
                headers: ["Content-Type": "application/json"],
                data: "{}".data(using: .utf8)!
            )
        }
    }

    func testBundleWillStart(_ testBundle: Bundle) {
        KarteApp.setLogLevel(.off)
        KarteApp.shared.teardown()
        Resolver.registerMockServices()
        URLProtocol.registerClass(HTTPStubProtocol.self)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        KarteApp.shared.teardown()
        UserDefaults.standard.removeObject(forKey: .nativeSDKConfig)
    }
}
