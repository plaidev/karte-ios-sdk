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

extension UITabBarController {
    class func krt_swizzleTabBarTransitionMethods() {
        exchangeInstanceMethod(
            from: #selector(setter: selectedIndex),
            to: #selector(krt_setSelectedIndex(_:))
        )
        exchangeInstanceMethod(
            from: #selector(setter: selectedViewController),
            to: #selector(krt_setSelectedViewController(_:))
        )
    }

    @objc
    private func krt_setSelectedIndex(_ index: Int) {
        if let window = view.window, let viewControllers = viewControllers, index < viewControllers.count {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.setSelectedViewController(viewControllers[index], in: window)
        }
        krt_setSelectedIndex(index)
    }

    @objc
    private func krt_setSelectedViewController(_ viewController: UIViewController) {
        if let window = view.window, let viewControllers = viewControllers, viewControllers.contains(viewController) {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.setSelectedViewController(viewController, in: window)
        }
        krt_setSelectedViewController(viewController)
    }
}
