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
class WindowDetectorSpec: XCTestCase {

    // MARK: - retrieveRelatedWindows(view:)

    func testRetrieveRelatedWindowsViewWithWindowScene() {
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)

        let windows = WindowDetector.retrieveRelatedWindows(view: view)

        guard let windowScene = view.window?.windowScene else {
            XCTFail("view.window?.windowScene is nil")
            return
        }
        XCTAssertEqual(windows, windowScene.windows, "returns windows from windowScene")
    }

    func testRetrieveRelatedWindowsViewWhenViewIsUIWindow() {
        let window = UIWindow()
        let windows = WindowDetector.retrieveRelatedWindows(view: window)

        guard window.windowScene != nil else {
            XCTFail("window.windowScene is nil")
            return
        }
        XCTAssertTrue(windows.contains(window), "returns array containing the window")
    }

    func testRetrieveRelatedWindowsViewWhenViewHasNoWindow() {
        let view = UIView()
        let windows = WindowDetector.retrieveRelatedWindows(view: view)
        XCTAssertTrue(windows.isEmpty, "returns empty array")
    }

    func testRetrieveRelatedWindowsViewWhenWindowHasNoWindowScene() {
        let window = UIWindow()
        let view = UIView()
        window.addSubview(view)
        window.windowScene = nil

        let windows = WindowDetector.retrieveRelatedWindows(view: view)
        XCTAssertTrue(windows.isEmpty, "returns empty array when no windowScene")
    }

    // MARK: - retrieveRelatedWindows(from:)

    func testRetrieveRelatedWindowsFromValidPersistentIdentifier() {
        let window = UIWindow()
        guard let scene = window.windowScene else {
            XCTFail("window.windowScene is nil")
            return
        }
        let persistentIdentifier = scene.session.persistentIdentifier
        let mockUIApplication = MockUIApplication()
        mockUIApplication.connectedScenes = [scene]

        let windows = WindowDetector.retrieveRelatedWindows(from: persistentIdentifier, application: mockUIApplication)
        XCTAssertEqual(windows, scene.windows, "returns windows from corresponding windowScene")
    }

    func testRetrieveRelatedWindowsFromNilIdentifierNoConnectedScenes() {
        let mockUIApplication = MockUIApplication()
        let windows = WindowDetector.retrieveRelatedWindows(from: nil, application: mockUIApplication)
        XCTAssertTrue(windows.isEmpty, "returns empty array when no connected windowScene")
    }

    func testRetrieveRelatedWindowsFromNilIdentifierWithConnectedScene() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let scene = window.windowScene!
        mockUIApplication.connectedScenes = [scene]
        let persistedIdentifier = scene.session.persistentIdentifier

        let windows = WindowDetector.retrieveRelatedWindows(from: nil, application: mockUIApplication)
        XCTAssertEqual(windows.first?.windowScene?.session.persistentIdentifier, persistedIdentifier, "returns windows from first connected windowScene")
    }

    func testRetrieveRelatedWindowsFromInvalidIdentifierNoConnectedScenes() {
        let mockUIApplication = MockUIApplication()
        let windows = WindowDetector.retrieveRelatedWindows(from: "invalid-identifier", application: mockUIApplication)
        XCTAssertTrue(windows.isEmpty, "returns empty array when no connected windowScene")
    }

    func testRetrieveRelatedWindowsFromInvalidIdentifierWithConnectedScene() {
        let mockUIApplication = MockUIApplication()
        let window = UIWindow()
        let scene = window.windowScene!
        mockUIApplication.connectedScenes = [scene]

        let windows = WindowDetector.retrieveRelatedWindows(from: "invalid-identifier", application: mockUIApplication)
        XCTAssertEqual(windows.first?.windowScene, scene, "returns windows from first connected windowScene")
    }

    func testRetrieveRelatedWindowsFromNilApplication() {
        let windows = WindowDetector.retrieveRelatedWindows(from: nil, application: nil)
        XCTAssertTrue(windows.isEmpty, "returns empty array when application is nil")
    }
}

class MockUIApplication: NSObject, UIApplicationProtocol {
    var connectedScenes: Set<UIScene> = []
}
