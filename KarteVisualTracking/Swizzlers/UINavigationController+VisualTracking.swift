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

extension UINavigationController {
    class func krt_vt_swizzleNavigationControllerMethods() {
        exchangeInstanceMethod(
            from: #selector(setViewControllers(_:animated:)),
            to: #selector(krt_vt_setViewControllers(_:animated:))
        )
        exchangeInstanceMethod(
            from: #selector(pushViewController(_:animated:)),
            to: #selector(krt_vt_pushViewController(_:animated:))
        )
        exchangeInstanceMethod(
            from: #selector(popViewController(animated:)),
            to: #selector(krt_vt_popViewController(animated:))
        )
        exchangeInstanceMethod(
            from: #selector(popToViewController(_:animated:)),
            to: #selector(krt_vt_popToViewController(_:animated:))
        )
        exchangeInstanceMethod(
            from: #selector(popToRootViewController(animated:)),
            to: #selector(krt_vt_popToRootViewController(animated:))
        )
    }

    @objc
    private func krt_vt_setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let action = Action(
            "setViewControllers",
            view: nil,
            viewController: viewControllers.last,
            targetText: nil
        )
        VisualTrackingManager.shared.dispatch(action: action)

        krt_vt_setViewControllers(viewControllers, animated: animated)
    }

    @objc
    private func krt_vt_pushViewController(_ viewController: UIViewController, animated: Bool) {
        let action = Action(
            "pushViewController",
            view: nil,
            viewController: visibleViewController,
            targetText: nil
        )
        VisualTrackingManager.shared.dispatch(action: action)

        krt_vt_pushViewController(viewController, animated: animated)
    }

    @objc
    private func krt_vt_popViewController(animated: Bool) -> UIViewController? {
        let action = Action(
            "popViewController",
            view: nil,
            viewController: visibleViewController,
            targetText: nil
        )
        VisualTrackingManager.shared.dispatch(action: action)

        return krt_vt_popViewController(animated: animated)
    }

    @objc
    private func krt_vt_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // swiftlint:disable:previous discouraged_optional_collection
        let action = Action(
            "popToViewController",
            view: nil,
            viewController: viewController,
            targetText: nil
        )
        VisualTrackingManager.shared.dispatch(action: action)

        return krt_vt_popToViewController(viewController, animated: animated)
    }

    @objc
    private func krt_vt_popToRootViewController(animated: Bool) -> [UIViewController]? {
        // swiftlint:disable:previous discouraged_optional_collection
        let action = Action(
            "popToRootViewController",
            view: nil,
            viewController: viewControllers.first,
            targetText: nil
        )
        VisualTrackingManager.shared.dispatch(action: action)

        return krt_vt_popToRootViewController(animated: animated)
    }
}
