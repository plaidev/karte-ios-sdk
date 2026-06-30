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
class ActionAppropriateViewDetectorSpec: XCTestCase {

    // MARK: - detect

    func testDetectReturnsUIViewWhenPassingUIView() {
        let view = UIView()
        guard let detected = UIKitAction.AppropriateViewDetector(view: view)?.detect() else {
            XCTFail("detected view should not be nil")
            return
        }
        XCTAssertTrue(type(of: detected) == UIView.self, "return is UIView")
    }

    func testDetectReturnsUITableViewCellWhenPassingContentView() {
        let cell = UITableViewCell()
        guard let detected = UIKitAction.AppropriateViewDetector(view: cell.contentView)?.detect() else {
            XCTFail("detected view should not be nil")
            return
        }
        XCTAssertTrue(detected is UITableViewCell, "return is UITableViewCell")
    }

    func testDetectReturnsUIButtonWhenEnabledButtonInCell() {
        let button = UIButton()
        let cell = UITableViewCell()
        cell.addSubview(button)

        guard let detected = UIKitAction.AppropriateViewDetector(view: button)?.detect() else {
            XCTFail("detected view should not be nil")
            return
        }
        XCTAssertTrue(detected is UIButton, "return is UIButton")
    }

    func testDetectReturnsUITableViewCellWhenDisabledButtonInCell() {
        let button = UIButton()
        button.isEnabled = false
        let cell = UITableViewCell()
        cell.addSubview(button)

        guard let detected = UIKitAction.AppropriateViewDetector(view: button)?.detect() else {
            XCTFail("detected view should not be nil")
            return
        }
        XCTAssertTrue(detected is UITableViewCell, "return is UITableViewCell")
    }

    // MARK: - isAppropriateView

    func testIsAppropriateViewTrueForUITableView() {
        let view = UITableView()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUIScrollView() {
        let view = UIScrollView()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUICollectionView() {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForEnabledUIButton() {
        let view = UIButton()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUILabelWithEnabledGesture() {
        let view = UILabel()
        view.addGestureRecognizer(UIGestureRecognizer())

        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUIImageViewWithEnabledGesture() {
        let view = UIImageView()
        view.addGestureRecognizer(UIGestureRecognizer())

        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUITableViewCell() {
        let view = UITableViewCell()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUIPickerView() {
        let view = UIPickerView()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewTrueForUIDatePicker() {
        let view = UIDatePicker()
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, true, "return true")
    }

    func testIsAppropriateViewFalseForDisabledUIButton() {
        let view = UIButton()
        view.isEnabled = false
        view.isUserInteractionEnabled = false

        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, false, "return false")
    }

    func testIsAppropriateViewFalseForUILabelWithDisabledGesture() {
        let gesture = UIGestureRecognizer()
        gesture.isEnabled = false
        let view = UILabel()
        view.addGestureRecognizer(gesture)

        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, false, "return false")
    }

    func testIsAppropriateViewFalseForUITableViewCellContentView() {
        let view = UITableViewCell().contentView
        let detector = UIKitAction.AppropriateViewDetector(view: view)
        XCTAssertEqual(detector?.isAppropriateView, false, "return false")
    }
}
