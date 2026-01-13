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

import Quick
import Nimble
import Mockingjay
import KarteUtilities
@testable import KarteCore
@testable import KarteVisualTracking

class DefinitionsRequestForDynamicFieldSpec: AsyncSpec {

    override class func spec() {
        var configuration: KarteCore.Configuration!
        var builder: Builder!

        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            builder = StubBuilder(spec: self, resource: .vt_definitions_with_dynamic_fields).build()
        }

        describe("a definition get") {
            var request: URLRequest!
            var mockStub: Stub!
            nonisolated(unsafe) var definitions: AutoTrackDefinition?

            beforeEach {
                mockStub = MockingjayProtocol.addStub(matcher: uri("/v0/native/auto-track/definitions"), builder: {(r) -> (Response) in
                    request = r
                    return builder(request)
                })
                KarteApp.setup(appKey: APP_KEY, configuration: configuration)

                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    VisualTrackingManager.shared.tracker?.refreshDefinitions {
                        continuation.resume()
                    }
                }
                definitions = VisualTrackingManager.shared.tracker?.definitions
            }

            afterEach {
                if mockStub != nil {
                    MockingjayProtocol.removeStub(mockStub)
                }
            }

            describe("its request") {
                it("has `X-KARTE-Auto-Track-OS` header") {
                    expect(request.allHTTPHeaderFields?.keys.contains("X-KARTE-Auto-Track-OS")).to(beTrue())
                }

                it("`X-KARTE-Auto-Track-OS` header value is `iOS`") {
                    expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-OS"]).to(equal("iOS"))
                }

                it("has `X-KARTE-Auto-Track-If-Modified-Since` header") {
                    expect(request.allHTTPHeaderFields?.keys.contains("X-KARTE-Auto-Track-If-Modified-Since")).to(beTrue())
                }

                it("`has X-KARTE-Auto-Track-If-Modified-Since` header that value is `0`") {
                    expect(request.allHTTPHeaderFields?["X-KARTE-Auto-Track-If-Modified-Since"]).to(equal("0"))
                }
            }

            describe("its definitions") {
                it("is not nil") {
                    expect(definitions).toNot(beNil())
                }

                it("only has valid trigger") {
                    expect(definitions?.definitions?.first?.triggers.count).to(equal(4))
                }

                it("only has valid conditions") {
                    if case let .and(c) = definitions?.definitions?.first?.triggers.first?.condition {
                        expect(c.count).to(equal(2))
                    } else {
                        fail()
                    }
                }
            }

            describe("its definitions with dynamic fields") {
                nonisolated(unsafe) var window: UIWindow!
                nonisolated(unsafe) var view1: UIView!
                nonisolated(unsafe) var view2: UIView!
                nonisolated(unsafe) var view3: UIView!
                nonisolated(unsafe) var label: UILabel!

                beforeEach {
                    await MainActor.run {
                        window = UIWindow()
                        view1 = UIView()
                        view2 = UIView()
                        view3 = UIView()
                        label = UILabel()
                        label.text = "test"
                        view1.addSubview(view2)
                        view1.addSubview(view3)
                        view1.addSubview(label)
                        window.addSubview(view1)
                    }
                }

                it("returns valid dynamic fields") {
                    let dynamicFieldsCount = definitions?.definitions?.first?.triggers.first?.dynamicFields?.count
                    expect(dynamicFieldsCount).to(equal(4))
                }

                it("returns valid dynamic values") {
                    await MainActor.run {
                        let dynamicValues = definitions?.definitions?.first?.triggers.first?.dynamicValues(window: window)
                        expect(dynamicValues?.count).to(equal(4))
                        expect(dynamicValues! as? [String: String]).to(equal(["foo":"test","bar":"test","baz":"test","has_unknown_key":"test"]))
                    }
                }

                it("returns invalid dynamic values for trigger 1") {
                    await MainActor.run {
                        let dynamicValues = definitions?.definitions?.first?.triggers[1].dynamicValues(window: window)
                        expect(dynamicValues).to(beNil())
                    }
                }

                it("returns invalid dynamic values for trigger 2") {
                    await MainActor.run {
                        let dynamicValues = definitions?.definitions?.first?.triggers[2].dynamicValues(window: window)
                        expect(dynamicValues).to(beNil())
                    }
                }

                it("returns invalid dynamic values for trigger 3") {
                    await MainActor.run {
                        let dynamicValues = definitions?.definitions?.first?.triggers[3].dynamicValues(window: window)
                        expect(dynamicValues).to(beNil())
                    }
                }
            }
        }
    }
}
