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

import KarteUtilities
import UIKit

extension UINavigationController {
    class func krt_swizzleNavigationTransitionMethods() {
        exchangeInstanceMethod(
            cls: self,
            from: #selector(setViewControllers(_:animated:)),
            to: #selector(krt_setViewControllers(_:animated:))
        )
        exchangeInstanceMethod(
            cls: self,
            from: #selector(pushViewController(_:animated:)),
            to: #selector(krt_pushViewController(_:animated:))
        )
        exchangeInstanceMethod(
            cls: self,
            from: #selector(popViewController(animated:)),
            to: #selector(krt_popViewController(animated:))
        )
        exchangeInstanceMethod(
            cls: self,
            from: #selector(popToViewController(_:animated:)),
            to: #selector(krt_popToViewController(_:animated:))
        )
        exchangeInstanceMethod(
            cls: self,
            from: #selector(popToRootViewController(animated:)),
            to: #selector(krt_popToRootViewController(animated:))
        )
    }

    @objc
    private func krt_setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let window = view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.pushViewController(viewControllers.last, to: self, in: window)
        }
        krt_setViewControllers(viewControllers, animated: animated)
    }

    @objc
    private func krt_pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let window = view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.pushViewController(viewController, to: self, in: window)
        }
        krt_pushViewController(viewController, animated: animated)
    }

    @objc
    private func krt_popViewController(animated: Bool) -> UIViewController? {
        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.popViewController(visibleViewController, from: self, in: view.window)

        return krt_popViewController(animated: animated)
    }

    @objc
    private func krt_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        // swiftlint:disable:previous discouraged_optional_collection
        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.popViewController(visibleViewController, from: self, in: view.window)

        return krt_popToViewController(viewController, animated: animated)
    }

    @objc
    private func krt_popToRootViewController(animated: Bool) -> [UIViewController]? {
        // swiftlint:disable:previous discouraged_optional_collection
        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.popViewController(visibleViewController, from: self, in: view.window)

        return krt_popToRootViewController(animated: animated)
    }
}
