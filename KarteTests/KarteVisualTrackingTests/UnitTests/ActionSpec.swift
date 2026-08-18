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
@testable import KarteCore
@testable import KarteVisualTracking

@MainActor
class ActionSpec: XCTestCase {

    // MARK: - init property

    // when a simple view structure
    func testInitSimpleViewStructure() throws {
        let viewController = UIViewController()
        let button = UIButton(type: .system)
        let action = try XCTUnwrap(
            UIKitAction(
                "dummy_action",
                view: button,
                viewController: viewController,
                targetText: "dummy_target_text",
                actionId: UIKitAction.actionId(view: button)
            )
        )

        XCTAssertEqual(action.action, "dummy_action", "action is `dummy_action`")
        XCTAssertIdentical(action.view, button, "view is UIButton")
        XCTAssertIdentical(action.viewController, viewController, "viewController is UIViewController")
        XCTAssertEqual(action.targetText, "dummy_target_text", "targetText is `dummy_target_text`")
        XCTAssertEqual(action.actionId, "UIButton", "actionId is `UIButton`")
    }

    // when a complex view structure: button index of actionId is 0
    func testInitComplexViewStructureButtonIndex0() throws {
        let viewController = UIViewController()
        let firstView = UIView()
        let secondView = UIView()
        let button0 = UIButton(type: .infoDark)
        let button1 = UIButton(type: .infoLight)
        firstView.addSubview(secondView)
        secondView.addSubview(button0)
        secondView.addSubview(button1)

        let action = try XCTUnwrap(
            UIKitAction(
                "dummy_action",
                view: button0,
                viewController: viewController,
                targetText: "dummy_target_text",
                actionId: UIKitAction.actionId(view: button0)
            )
        )
        XCTAssertEqual(action.actionId, "UIButton0UIView0UIView", "button index of actionId is 0")
    }

    // when a complex view structure: button index of actionId is 1
    func testInitComplexViewStructureButtonIndex1() throws {
        let viewController = UIViewController()
        let firstView = UIView()
        let secondView = UIView()
        let button0 = UIButton(type: .infoDark)
        let button1 = UIButton(type: .infoLight)
        firstView.addSubview(secondView)
        secondView.addSubview(button0)
        secondView.addSubview(button1)

        let action = try XCTUnwrap(
            UIKitAction(
                "dummy_action",
                view: button1,
                viewController: viewController,
                targetText: "dummy_target_text",
                actionId: UIKitAction.actionId(view: button1)
            )
        )
        XCTAssertEqual(action.actionId, "UIButton1UIView0UIView", "button index of actionId is 1")
    }

    // when a complex view structure: actionId is overridden by argument
    func testInitActionIdOverriddenByArgument() throws {
        let viewController = UIViewController()
        let button = UIButton(type: .infoLight)
        let action = try XCTUnwrap(
            UIKitAction(
                "dummy_action",
                view: button,
                viewController: viewController,
                targetText: "dummy_target_text",
                actionId: "dummy_action_id"
            )
        )
        XCTAssertEqual(action.actionId, "dummy_action_id", "actionId is overridden by argument")
    }

    // when view is nil: actionId is nil
    func testInitActionIdIsNil() throws {
        let viewController = UIViewController()
        let action = try XCTUnwrap(
            UIKitAction(
                "dummy_action",
                view: nil,
                viewController: viewController,
                targetText: "dummy_target_text"
            )
        )
        XCTAssertNil(action.actionId, "actionId is nil")
    }

    // when pass an ignore action name
    func testInitIgnoreActionName() {
        let action = UIKitAction(
            "handlePan:",
            view: UIView(),
            viewController: UIViewController(),
            targetText: "dummy_target_text"
        )
        XCTAssertNil(action, "ignore action name returns nil")
    }

    // when pass nil for view / viewController
    func testInitNilViewAndViewController() throws {
        let action = try XCTUnwrap(
            UIKitAction(
                "test_action",
                view: nil,
                viewController: nil,
                targetText: "dummy_target_text"
            )
        )
        XCTAssertNil(action.screenName, "screenName returns nil")
        XCTAssertNil(action.screenHostName, "screenHostName returns nil")
    }

    // when pass nil for view / viewController / targetText
    func testInitAllNil() {
        let action = UIKitAction(
            "test_action",
            view: nil,
            viewController: nil,
            targetText: nil
        )
        XCTAssertNil(action, "passing nil for view / viewController / targetText returns nil")
    }

    // MARK: - viewPathIndices

    // when passing nil
    func testViewPathIndicesWithNil() {
        XCTAssertEqual(UIKitAction.viewPathIndices(actionId: nil), [], "passing nil returns empty array")
    }

    // when passing empty string
    func testViewPathIndicesWithEmptyString() {
        XCTAssertEqual(UIKitAction.viewPathIndices(actionId: ""), [], "passing empty string returns empty array")
    }

    // when passing UIView
    func testViewPathIndicesWithUIView() {
        XCTAssertEqual(UIKitAction.viewPathIndices(actionId: "UIView"), [], "passing UIView returns empty array")
    }

    // when passing UIView0
    func testViewPathIndicesWithUIView0() {
        XCTAssertEqual(UIKitAction.viewPathIndices(actionId: "UIView0"), [0], "passing UIView0 returns array with 0")
    }

    // when passing complexView
    func testViewPathIndicesWithComplexView() {
        let actual = UIKitAction.viewPathIndices(actionId: "UIView11UITableView0UIView0UIViewControllerWrapperView0UINavigationTransitionView0UILayoutContainerView0UIDropShadowView0UITransitionView0SimpleUIWindow")
        XCTAssertEqual(actual, [0, 0, 0, 0, 0, 0, 0, 11], "passing complexView returns array with 0,0,0,0,0,0,0,11")
    }

    // when passing UIView999UIView2000UIView3000
    func testViewPathIndicesWithMultipleIndices() {
        XCTAssertEqual(UIKitAction.viewPathIndices(actionId: "UIView999UIView2000UIView3000"), [3000, 2000, 999], "passing UIView999UIView2000UIView3000 returns array with 3000,2000,999")
    }
}
