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
@testable import KarteVisualTracking

@MainActor
class InspectorSpec: XCTestCase {

    func testInspectView() {
        let window = UIWindow()
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        let view4 = UIView()
        view1.addSubview(view2)
        view2.addSubview(view3)
        view2.addSubview(view4)
        window.addSubview(view1)

        // when passing inWindow nil
        XCTAssertNil(Inspector.inspectView(with: [0], inWindow: nil), "passing inWindow nil returns nil")

        // when passing empty array
        XCTAssertNil(Inspector.inspectView(with: [], inWindow: UIWindow()), "passing empty array returns nil")

        // when passing out-of-bounds indices
        let outOfBoundsIndices = UIKitAction.viewPathIndices(actionId: "Olympic0View11UIView0")
        XCTAssertNil(Inspector.inspectView(with: outOfBoundsIndices, inWindow: window), "passing out-of-bounds indices returns nil")

        // when passing UIView1UIView0UIView0UIWindow
        let actionId = UIKitAction.actionId(view: view4)
        XCTAssertEqual(actionId, "UIView1UIView0UIView0UIWindow", "actionId")
        let viewPathIndices = UIKitAction.viewPathIndices(actionId: actionId)
        XCTAssertNotNil(Inspector.inspectView(with: viewPathIndices, inWindow: window), "passing valid viewPath returns not nil")
    }

    func testInspectText() {
        // when passing nil
        XCTAssertNil(Inspector.inspectText(with: nil), "passing nil returns nil")

        // when passing UIButton that has not text
        XCTAssertNil(Inspector.inspectText(with: UIButton(type: .infoDark)), "passing UIButton that has not text returns nil")

        // when passing UIButton that has text
        let button = UIButton(type: .system)
        button.titleLabel?.text = "text"
        XCTAssertEqual(Inspector.inspectText(with: button), "text", "passing UIButton that has text returns text")

        // when passing superView of UILabel
        let view = UIView()
        let label = UILabel()
        label.text = "text"
        view.addSubview(label)
        XCTAssertEqual(Inspector.inspectText(with: view), "text", "passing superView of UILabel returns text")

        // when passing UITabBarItem
        let tabBar = UITabBarItem()
        tabBar.title = "text"
        XCTAssertEqual(Inspector.inspectText(with: tabBar), "text", "passing UITabBarItem returns text")
    }

    func testTakeSnapshot() {
        // when passing nil
        XCTAssertNil(Inspector.takeSnapshot(with: nil), "passing nil returns nil")

        // when passing UIButton
        XCTAssertNotNil(Inspector.takeSnapshot(with: UIButton(type: .infoDark)), "passing UIButton returns not nil")
    }
}
