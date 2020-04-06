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

extension UIResponder {
    class func krt_vt_retrieveViewController(for target: Any?) -> UIViewController? {
        if let responder = target as? UIResponder, let viewController = responder.krt_vt_retrieveViewController() as? UIViewController {
            return viewController
        } else {
            return nil
        }
    }

    private func krt_vt_retrieveViewController() -> UIResponder? {
        if let viewController = next as? UIViewController {
            return viewController
        } else if let view = next as? UIView {
            return view.krt_vt_retrieveViewController()
        } else {
            return nil
        }
    }
}
