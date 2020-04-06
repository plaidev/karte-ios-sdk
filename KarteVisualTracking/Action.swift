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

import UIKit

internal struct Action {
    static let ignoreActions = ["handlePan:", "handlePanGesture:", "handlePinchGesture:", "handleTouchMonitor:", "handleTiltGesture:"]

    var action: String
    var view: UIView?
    var viewController: UIViewController?
    var targetText: String?
    var actionId: String?

    var viewName: String? {
        guard let view = view else {
            return nil
        }
        return String(describing: type(of: view))
    }

    var viewControllerName: String? {
        guard let viewController = viewController else {
            return nil
        }
        return String(describing: type(of: viewController))
    }

    init?(_ action: String, view: UIView?, viewController: UIViewController?, targetText: String?) {
        if Action.ignoreActions.contains(action) {
            return nil
        }
        if view == nil && viewController == nil && targetText == nil {
            return nil
        }

        self.action = action
        self.view = AppropriateViewDetector(view: view)?.detect()
        self.viewController = viewController
        self.targetText = targetText
        self.actionId = Action.actionId(view: self.view)
    }
}

extension Action {
    private static func actionId(view: UIView?) -> String? {
        guard view != nil else {
            return nil
        }

        var actionId = ""
        var targetView = view
        while let tView = targetView {
            if let superView = tView.superview {
                actionId.append(String(describing: type(of: tView)))
                if let index = superView.subviews.firstIndex(where: { $0.isEqual(tView) }) {
                    actionId.append(String(index))
                    targetView = superView
                }
            } else {
                actionId.append(String(describing: type(of: tView)))
                targetView = nil
            }
        }
        return actionId
    }
}

extension Action {
    struct AppropriateViewDetector {
        var view: UIView

        init?(view: UIView?) {
            guard let view = view else {
                return nil
            }
            self.view = view
        }

        func detect() -> UIView? {
            if isAppropriateView {
                return view
            }

            func _detect(from view: UIView) -> UIView? {
                var targetView: UIView? = view
                while let tView = targetView {
                    switch targetView {
                    case is UITableViewCell, is UICollectionViewCell, is UIPickerView, is UINavigationBar:
                        return tView

                    default:
                        targetView = tView.superview
                    }
                }
                return view
            }

            return _detect(from: view)
        }

        var isAppropriateView: Bool {
            switch view {
            case is UIScrollView, is UITableViewCell, is UICollectionViewCell, is UIPickerView, is UINavigationBar:
                return true

            case is UILabel, is UIImageView:
                let gestureRecognizers = view.gestureRecognizers ?? []
                return gestureRecognizers.contains { $0.isEnabled }

            case let view as UIControl where view.isUserInteractionEnabled && view.isEnabled:
                return true

            default:
                return false
            }
        }
    }
}

extension Action: CustomStringConvertible {
    var description: String {
        let cls = String(describing: type(of: self))
        let values = [
            "action": action,
            "view": viewName ?? "",
            "view_controller": viewControllerName ?? "",
            "target_text": targetText ?? "",
            "action_id": actionId ?? ""
        ]
        return "<\(cls): \(values)>"
    }
}
