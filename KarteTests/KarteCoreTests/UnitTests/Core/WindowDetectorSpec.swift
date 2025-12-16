//
//  Copyright 2025 PLAID, Inc.
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
import UIKit
@testable import KarteCore

class WindowDetectorSpec: QuickSpec {
    override class func spec() {
        describe("WindowDetector") {
            describe("retrieveRelatedWindows(view:)") {
                context("when view has window with windowScene") {
                    it("returns windows from windowScene") {
                        let window = UIWindow()
                        let view = UIView()
                        window.addSubview(view)

                        let windows = WindowDetector.retrieveRelatedWindows(view: view)

                        if let windowScene = view.window?.windowScene {
                            expect(windows).to(equal(windowScene.windows))
                        } else {
                            fail()
                        }
                    }
                }

                context("when view is UIWindow itself") {
                    it("returns array containing the window") {
                        let window = UIWindow()
                        let windows = WindowDetector.retrieveRelatedWindows(view: window)

                        if window.windowScene != nil {
                            expect(windows.contains(window)).to(beTrue())
                        } else {
                            fail()
                        }
                    }
                }

                context("when view has no window") {
                    it("returns empty array") {
                        let view = UIView()

                        let windows = WindowDetector.retrieveRelatedWindows(view: view)

                        expect(windows).to(beEmpty())
                    }
                }

                context("when view window has no windowScene") {
                    it("returns empty array") {
                        let window = UIWindow()
                        let view = UIView()
                        window.addSubview(view)
                        window.windowScene = nil

                        let windows = WindowDetector.retrieveRelatedWindows(view: view)

                        expect(windows).to(beEmpty())
                    }
                }
            }

            describe("retrieveRelatedWindows(from:)") {
                context("when valid persistentIdentifier is provided") {
                    it("returns windows from corresponding windowScene") {
                        let window = UIWindow()
                        guard let scene = window.windowScene else {
                            fail("window.windowScene is nil")
                            return
                        }
                        let persistentIdentifier = scene.session.persistentIdentifier
                        let mockUIApplication = MockUIApplication()
                        mockUIApplication.connectedScenes = [scene]

                        let windows = WindowDetector.retrieveRelatedWindows(from: persistentIdentifier, application: mockUIApplication)

                        expect(windows).to(equal(scene.windows))
                    }
                }

                context("when persistentIdentifier is nil") {
                    it("returns empty array when no connected windowScene") {
                        let mockUIApplication = MockUIApplication()
                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: nil,
                            application: mockUIApplication
                        )

                        expect(windows).to(beEmpty())
                    }
                    it("returns windows from first connected windowScene when connectedScenes is not empty") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let scene = window.windowScene!
                        mockUIApplication.connectedScenes = [scene]
                        let persistedIdentifier = scene.session.persistentIdentifier
                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: nil,
                            application: mockUIApplication
                        )

                        expect(windows.first?.windowScene?.session.persistentIdentifier).to(equal(persistedIdentifier))
                    }
                }

                context("when invalid persistentIdentifier is provided") {
                    it("returns empty array when no connected windowScene") {
                        let mockUIApplication = MockUIApplication()
                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: "invalid-identifier",
                            application: mockUIApplication
                        )

                        expect(windows).to(beEmpty())
                    }
                    it("returns windows from first connected windowScene when connectedScenes is not empty") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let scene = window.windowScene!
                        mockUIApplication.connectedScenes = [scene]

                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: "invalid-identifier",
                            application: mockUIApplication
                        )

                        expect(windows.first?.windowScene).to(equal(scene))                    }
                }

                context("when no connected scenes exist") {
                    it("returns empty array") {
                        let mockUIApplication = MockUIApplication()

                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: nil,
                            application: mockUIApplication
                        )

                        expect(windows).to(beEmpty())
                    }
                }

                context("when application is nil") {
                    it("returns empty array") {
                        let windows = WindowDetector.retrieveRelatedWindows(
                            from: nil,
                            application: nil
                        )

                        expect(windows).to(beEmpty())
                    }
                }
            }
        }
    }
}

class MockUIApplication: NSObject, UIApplicationProtocol {
    var connectedScenes: Set<UIScene> = []
}
