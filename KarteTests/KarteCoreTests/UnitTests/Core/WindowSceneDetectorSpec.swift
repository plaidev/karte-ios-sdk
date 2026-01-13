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

class WindowSceneDetectorSpec: QuickSpec {
    override class func spec() {
        describe("WindowSceneDetector") {
            describe("retrievePersistentIdentifiers()") {
                context("when UIApplication responds to connectedScenes") {
                    it("returns array of persistent identifiers from connected scenes") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let scene = window.windowScene!

                        mockUIApplication.connectedScenes = [scene]

                        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: mockUIApplication)

                        expect(identifiers).toNot(beNil())
                        expect(identifiers?.count).to(equal(1))
                    }
                }

                context("when there are no connected scenes") {
                    it("returns empty array") {
                        let mockUIApplication = MockUIApplication()
                        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: mockUIApplication)

                        expect(identifiers?.count).to(equal(0))
                    }
                }
                context("when UIApplication is nil") {
                    it("return nil") {
                        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: nil)
                        expect(identifiers).to(beNil())
                    }
                }
            }

            describe("retrievePersistentIdentifier(view:)") {
                context("when view has window with windowScene") {
                    it("returns persistent identifier from windowScene") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let view = UIView()
                        window.addSubview(view)

                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

                        expect(identifier).to(equal(view.window?.windowScene?.session.persistentIdentifier))
                    }
                }

                context("when view is UIWindow itself") {
                    it("returns persistent identifier from window's windowScene") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()

                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: window, application: mockUIApplication)

                        expect(identifier).to(equal(window.windowScene?.session.persistentIdentifier))
                    }
                }

                context("when view has no window") {
                    it("returns identifier from first connected scene if available") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let scene = window.windowScene!
                        mockUIApplication.connectedScenes = [scene]
                        let view = UIView()

                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

                        expect(identifier).to(equal(scene.session.persistentIdentifier))
                    }
                }

                context("when view is nil") {
                    it("returns identifier from first connected scene if available") {
                        let mockUIApplication = MockUIApplication()
                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: nil, application: mockUIApplication)

                        expect(identifier).to(beNil())
                    }
                }

                context("when view window has no windowScene") {
                    it("returns identifier from first connected scene if available") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        let view = UIView()
                        window.addSubview(view)
                        window.windowScene = nil

                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

                        expect(identifier).to(beNil())
                    }
                }

                context("when UIApplication is nil") {
                    it("return nil") {
                        let view = UIView()
                        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: nil)
                        expect(identifier).to(beNil())
                    }
                }
            }

            describe("retrieveWindowScene(from:application:)") {
                context("when valid persistentIdentifier is provided") {
                    it("returns corresponding windowScene") {
                        let window = UIWindow()
                        guard let scene = window.windowScene else {
                            fail("window.windowScene is nil")
                            return
                        }
                        let persistentIdentifier = scene.session.persistentIdentifier
                        let mockUIApplication = MockUIApplication()
                        mockUIApplication.connectedScenes = [scene]

                        let windowScene = WindowSceneDetector.retrieveWindowScene(
                            from: persistentIdentifier,
                            application: mockUIApplication
                        )

                        expect(windowScene).to(equal(scene))
                    }
                }

                context("when persistentIdentifier is nil") {
                    it("returns nil when no connected scenes") {
                        let mockUIApplication = MockUIApplication()

                        let windowScene = WindowSceneDetector.retrieveWindowScene(
                            from: nil,
                            application: mockUIApplication
                        )

                        expect(windowScene).to(beNil())
                    }
                }

                context("when invalid persistentIdentifier is provided") {
                    it("returns nil when no matching scene") {
                        let mockUIApplication = MockUIApplication()
                        let window = UIWindow()
                        if let scene = window.windowScene {
                            mockUIApplication.connectedScenes = [scene]
                        }

                        let windowScene = WindowSceneDetector.retrieveWindowScene(
                            from: "invalid-identifier",
                            application: mockUIApplication
                        )

                        expect(windowScene).to(beNil())
                    }
                }

                context("when application is nil") {
                    it("returns nil") {
                        let windowScene = WindowSceneDetector.retrieveWindowScene(
                            from: "any-identifier",
                            application: nil
                        )

                        expect(windowScene).to(beNil())
                    }
                }

                context("when application does not respond to connectedScenes") {
                    it("returns nil") {
                        let mockUIApplication = MockUIApplication()

                        let windowScene = WindowSceneDetector.retrieveWindowScene(
                            from: "any-identifier",
                            application: mockUIApplication
                        )

                        expect(windowScene).to(beNil())
                    }
                }
            }
        }
    }
}
