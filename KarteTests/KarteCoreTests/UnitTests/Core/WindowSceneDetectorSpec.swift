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

import XCTest
import UIKit
@testable import KarteCore

@MainActor
class WindowSceneDetectorSpec: XCTestCase {

    // MARK: - retrievePersistentIdentifiers()

    func testRetrievePersistentIdentifiers() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let scene = window.windowScene!
        mockUIApplication.connectedScenes = [scene]

        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: mockUIApplication)

        XCTAssertNotNil(identifiers, "identifiers should not be nil")
        XCTAssertEqual(identifiers?.count, 1, "identifiers count")
    }

    func testRetrievePersistentIdentifiersWhenNoConnectedScenes() {
        let mockUIApplication = MockUIApplication()
        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: mockUIApplication)

        XCTAssertEqual(identifiers?.count, 0, "empty array when no connected scenes")
    }

    func testRetrievePersistentIdentifiersWhenApplicationIsNil() {
        let identifiers = WindowSceneDetector.retrievePersistentIdentifiers(application: nil)
        XCTAssertNil(identifiers, "nil when application is nil")
    }

    // MARK: - retrievePersistentIdentifier(view:)

    func testRetrievePersistentIdentifierWithViewInWindow() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)

        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

        XCTAssertEqual(identifier, view.window?.windowScene?.session.persistentIdentifier, "identifier from windowScene")
    }

    func testRetrievePersistentIdentifierWithUIWindow() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()

        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: window, application: mockUIApplication)

        XCTAssertEqual(identifier, window.windowScene?.session.persistentIdentifier, "identifier from window's windowScene")
    }

    func testRetrievePersistentIdentifierWhenViewHasNoWindow() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let scene = window.windowScene!
        mockUIApplication.connectedScenes = [scene]
        let view = UIView()

        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

        XCTAssertEqual(identifier, scene.session.persistentIdentifier, "identifier from first connected scene")
    }

    func testRetrievePersistentIdentifierWhenViewIsNil() {
        let mockUIApplication = MockUIApplication()
        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: nil, application: mockUIApplication)

        XCTAssertNil(identifier, "nil when view is nil")
    }

    func testRetrievePersistentIdentifierWhenWindowSceneIsNil() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)
        window.windowScene = nil

        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: mockUIApplication)

        XCTAssertNil(identifier, "nil when windowScene is nil")
    }

    func testRetrievePersistentIdentifierWhenApplicationIsNil() {
        let view = UIView()
        let identifier = WindowSceneDetector.retrievePersistentIdentifier(view: view, application: nil)
        XCTAssertNil(identifier, "nil when application is nil")
    }

    // MARK: - retrieveWindowScene(from:application:)

    func testRetrieveWindowSceneWithValidIdentifier() {
        let window = UIWindow()
        guard let scene = window.windowScene else {
            XCTFail("window.windowScene is nil")
            return
        }
        let persistentIdentifier = scene.session.persistentIdentifier
        let mockUIApplication = MockUIApplication()
        mockUIApplication.connectedScenes = [scene]

        let windowScene = WindowSceneDetector.retrieveWindowScene(
            from: persistentIdentifier,
            application: mockUIApplication
        )

        XCTAssertEqual(windowScene, scene, "returns corresponding windowScene")
    }

    func testRetrieveWindowSceneWhenIdentifierIsNil() {
        let mockUIApplication = MockUIApplication()

        let windowScene = WindowSceneDetector.retrieveWindowScene(
            from: nil,
            application: mockUIApplication
        )

        XCTAssertNil(windowScene, "nil when persistentIdentifier is nil")
    }

    func testRetrieveWindowSceneWithInvalidIdentifier() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        if let scene = window.windowScene {
            mockUIApplication.connectedScenes = [scene]
        }

        let windowScene = WindowSceneDetector.retrieveWindowScene(
            from: "invalid-identifier",
            application: mockUIApplication
        )

        XCTAssertNil(windowScene, "nil when no matching scene")
    }

    func testRetrieveWindowSceneWhenApplicationIsNil() {
        let windowScene = WindowSceneDetector.retrieveWindowScene(
            from: "any-identifier",
            application: nil
        )

        XCTAssertNil(windowScene, "nil when application is nil")
    }

    func testRetrieveWindowSceneWhenNoConnectedScenes() {
        let mockUIApplication = MockUIApplication()

        let windowScene = WindowSceneDetector.retrieveWindowScene(
            from: "any-identifier",
            application: mockUIApplication
        )

        XCTAssertNil(windowScene, "nil when no connected scenes")
    }
}
