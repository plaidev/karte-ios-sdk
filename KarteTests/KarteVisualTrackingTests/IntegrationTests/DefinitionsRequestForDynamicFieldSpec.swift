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

@MainActor
class DefinitionsRequestForDynamicFieldSpec: XCTestCase {

    private func loadDefinitions() -> (definitions: AutoTrackDefinition?, request: URLRequest?) {
        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        let builder = StubBuilder(spec: Self.self, resource: .vt_definitions_with_dynamic_fields).build()

        nonisolated(unsafe) var capturedRequest: URLRequest?
        let mockStub = HTTPStubProtocol.addStub(matcher: uri("/v0/native/auto-track/definitions"), builder: { r in
            capturedRequest = r
            return builder(r)
        })
        defer {
            HTTPStubProtocol.removeStub(mockStub)
        }

        KarteApp.setup(appKey: APP_KEY, configuration: configuration)

        let exp = expectation(description: "refreshDefinitions")
        VisualTrackingManager.shared.tracker?.refreshDefinitions {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        return (VisualTrackingManager.shared.tracker?.definitions, capturedRequest)
    }

    func testRequestHeaders() {
        guard let request = loadDefinitions().request else {
            XCTFail("request should not be nil")
            return
        }
        let headers = request.allHTTPHeaderFields
        XCTAssertTrue(headers?.keys.contains("X-KARTE-Auto-Track-OS") ?? false, "has `X-KARTE-Auto-Track-OS` header")
        XCTAssertEqual(headers?["X-KARTE-Auto-Track-OS"], "iOS", "`X-KARTE-Auto-Track-OS` header value is `iOS`")
        XCTAssertTrue(headers?.keys.contains("X-KARTE-Auto-Track-If-Modified-Since") ?? false, "has `X-KARTE-Auto-Track-If-Modified-Since` header")
        XCTAssertEqual(headers?["X-KARTE-Auto-Track-If-Modified-Since"], "0", "`X-KARTE-Auto-Track-If-Modified-Since` header value is `0`")
    }

    func testDefinitionsRequestAndDefinitions() {
        guard let definitions = loadDefinitions().definitions else {
            XCTFail("definitions should not be nil")
            return
        }
        XCTAssertEqual(definitions.definitions?.first?.triggers.count, 4, "only has valid trigger")
        if case let .and(c) = definitions.definitions?.first?.triggers.first?.condition {
            XCTAssertEqual(c.count, 2, "only has valid conditions")
        } else {
            XCTFail("condition should be .and")
        }
    }

    func testDefinitionsWithDynamicFields() {
        guard let definitions = loadDefinitions().definitions else {
            XCTFail("definitions should not be nil")
            return
        }

        let window = UIWindow()
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let label = UILabel()
        label.text = "test"
        view1.addSubview(view2)
        view1.addSubview(view3)
        view1.addSubview(label)
        window.addSubview(view1)

        let dynamicFieldsCount = definitions.definitions?.first?.triggers.first?.dynamicFields?.count
        XCTAssertEqual(dynamicFieldsCount, 4, "returns valid dynamic fields")

        let dynamicValues = definitions.definitions?.first?.triggers.first?.dynamicValues(window: window)
        XCTAssertEqual(dynamicValues?.count, 4, "returns valid dynamic values count")
        XCTAssertEqual(dynamicValues as? [String: String], ["foo": "test", "bar": "test", "baz": "test", "has_unknown_key": "test"], "returns valid dynamic values")

        XCTAssertNil(definitions.definitions?.first?.triggers[1].dynamicValues(window: window), "returns invalid dynamic values for trigger 1")
        XCTAssertNil(definitions.definitions?.first?.triggers[2].dynamicValues(window: window), "returns invalid dynamic values for trigger 2")
        XCTAssertNil(definitions.definitions?.first?.triggers[3].dynamicValues(window: window), "returns invalid dynamic values for trigger 3")
    }
}
