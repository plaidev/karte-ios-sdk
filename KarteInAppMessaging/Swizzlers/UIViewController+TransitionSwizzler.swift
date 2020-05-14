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

extension UIViewController {
    class func krt_swizzleTransitionMethods() {
        exchangeInstanceMethod(
            cls: self,
            from: #selector(present(_:animated:completion:)),
            to: #selector(krt_presentViewController(_:animated:completion:))
        )
        exchangeInstanceMethod(
            cls: self,
            from: #selector(dismiss(animated:completion:)),
            to: #selector(krt_dismissViewController(animated:completion:))
        )
    }

    @objc
    private func krt_presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.presentViewController(viewController, in: view.window)

        krt_presentViewController(viewController, animated: animated, completion: completion)
    }

    @objc
    private func krt_dismissViewController(animated: Bool, completion: (() -> Void)?) {
        var viewController = self
        while let tempViewController = viewController.presentedViewController {
            viewController = tempViewController
        }

        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.dismissViewController(viewController, in: view.window)

        krt_dismissViewController(animated: animated, completion: completion)
    }
}
