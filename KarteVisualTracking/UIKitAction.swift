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

/// 画像を生成して返す関数を表す型です。
public typealias ImageProvider = () -> UIImage?

/// Actionの生成を行う列挙型です。
public enum ActionFactory {
    /// Actionを返します。<br>
    ///
    /// view / viewController / targetText が全て nil の場合は初期化に失敗して nil を返します。<br>
    /// アクションIDにはアプリ再起動時も変化しない一意なIDを設定してください。
    ///
    /// - Parameter actionName: アクション名
    /// - Parameter view: UIView
    /// - Parameter viewController: UIViewController
    /// - Parameter targetText: ターゲット文字列（Viewコンポーネントのタイトルなどを設定します。）
    /// - Parameter actionId: アクションID
    /// - Parameter imageProvider: 操作ログに添付する画像を返す関数（ペアリング時の操作ログ送信でのみ利用されます。）
    /// - Returns: ActionProtocol
    public static func createForUIKit(
        actionName: String,
        view: UIView?,
        viewController: UIViewController?,
        targetText: String?,
        actionId: String?,
        imageProvider: ImageProvider? = nil
    ) -> ActionProtocol? {
        UIKitAction(
            actionName,
            view: view,
            viewController: viewController,
            targetText: targetText,
            actionId: actionId,
            imageProvider: UIKitAction.defaultImageProvider(view: view, viewController: viewController)
        )
    }
}

/// UIKit用のアクションを表現する型です。
internal protocol UIKitActionProtocol: ActionProtocol {
    /// UIViewを返します
    var view: UIView? { get }

    /// UIViewControllerを返します
    var viewController: UIViewController? { get }

    /// View名を返します
    var viewName: String? { get }

    /// ViewController名を返します
    var viewControllerName: String? { get }
}

extension UIKitActionProtocol {
    /// スクリーン名を返します
    var screenName: String? {
        viewName
    }

    /// Viewホスト名を返します
    var screenHostName: String? {
        viewControllerName
    }
}

internal struct UIKitAction: UIKitActionProtocol {
    static let ignoreActions = ["handlePan:", "handlePanGesture:", "handlePinchGesture:", "handleTouchMonitor:", "handleTiltGesture:"]

    var action: String
    var view: UIView?
    var viewController: UIViewController?
    var targetText: String?
    var actionId: String?
    var imageProvider: ImageProvider?

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

    init?(_ action: String, view: UIView?, viewController: UIViewController?, targetText: String?, imageProvider: ImageProvider? = nil) {
        guard UIKitAction.validate(actoionName: action, view: view, viewController: viewController, targetText: targetText) else {
            return nil
        }

        self.action = action
        self.view = AppropriateViewDetector(view: view)?.detect()
        self.viewController = viewController
        self.targetText = targetText
        self.actionId = UIKitAction.actionId(view: self.view)
        self.imageProvider = imageProvider ?? Self.defaultImageProvider(view: view, viewController: viewController)
    }

    init?(_ action: String, view: UIView?, viewController: UIViewController?, targetText: String?, actionId: String?, imageProvider: ImageProvider? = nil) {
        guard UIKitAction.validate(actoionName: action, view: view, viewController: viewController, targetText: targetText) else {
            return nil
        }

        self.action = action
        self.view = AppropriateViewDetector(view: view)?.detect()
        self.viewController = viewController
        self.targetText = targetText
        self.actionId = actionId
        self.imageProvider = imageProvider ?? Self.defaultImageProvider(view: view, viewController: viewController)
    }

    static func defaultImageProvider(view: UIView?, viewController: UIViewController?) -> ImageProvider {
        { Inspector.takeSnapshot(with: view) ?? Inspector.takeSnapshot(with: viewController?.view) }
    }

    private static func validate(actoionName: String, view: UIView?, viewController: UIViewController?, targetText: String?) -> Bool {
        if UIKitAction.ignoreActions.contains(actoionName) {
            return false
        }
        if view == nil && viewController == nil && targetText == nil {
            return false
        }
        return true
    }

    func image() -> UIImage? {
        imageProvider?()
    }
}

extension UIKitAction {
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

extension UIKitAction {
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

extension UIKitAction: CustomStringConvertible {
    public var description: String {
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
