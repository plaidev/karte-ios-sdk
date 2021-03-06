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
    class func krt_swizzleLifecycleMethods() {
        exchangeInstanceMethod(
            cls: self,
            from: #selector(viewDidAppear(_:)),
            to: #selector(krt_viewDidAppear(_:))
        )
    }

    @objc
    private func krt_viewDidAppear(_ animated: Bool) {
        krt_viewDidAppear(animated)

        let process = InAppMessaging.shared.retrieveProcess(window: view.window)
        process?.viewDidAppearFromViewController(self)
    }
}
