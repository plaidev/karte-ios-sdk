//
//  Copyright 2021 PLAID, Inc.
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

func mockImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
        UIColor.red.setFill()
        rendererContext.fill(CGRect(origin: .zero, size: size))
    }
}

@MainActor
class ActionFactorySpec: XCTestCase {

    func testCreateForUIKitWithoutImageProvider() {
        guard let action = ActionFactory.createForUIKit(actionName: "test_touch",
                                                        view: UIView(frame: .init(x: 0, y: 0, width: 100, height: 100)),
                                                        viewController: nil,
                                                        targetText: "test_text",
                                                        actionId: "test_action_id") else {
            XCTFail("action should not be nil")
            return
        }
        XCTAssertEqual(action.action, "test_touch", "action is `touch`")
        XCTAssertNotNil(action.screenName, "screenName is not nil")
        XCTAssertNil(action.screenHostName, "screenHostName is nil")
        XCTAssertEqual(action.targetText, "test_text", "targetText is `test_text`")
        XCTAssertEqual(action.actionId, "test_action_id", "actionId is `test_action_id`")
        XCTAssertNotNil(action.image(), "image is not nil")
    }

    func testCreateForUIKitWithImageProvider() {
        let image = mockImage()
        guard let action = ActionFactory.createForUIKit(actionName: "test_touch",
                                                        view: UIView(frame: .init(x: 0, y: 0, width: 100, height: 100)),
                                                        viewController: nil,
                                                        targetText: "test_text",
                                                        actionId: "test_action_id",
                                                        imageProvider: { image }) else {
            XCTFail("action should not be nil")
            return
        }
        XCTAssertEqual(action.action, "test_touch", "action is `touch`")
        XCTAssertNotNil(action.screenName, "screenName is not nil")
        XCTAssertNil(action.screenHostName, "screenHostName is nil")
        XCTAssertEqual(action.targetText, "test_text", "targetText is `test_text`")
        XCTAssertEqual(action.actionId, "test_action_id", "actionId is `test_action_id`")
        XCTAssertNotNil(action.image(), "image is not nil")
        XCTAssertEqual(action.image(), image, "action.image is equal to image")
    }
}
