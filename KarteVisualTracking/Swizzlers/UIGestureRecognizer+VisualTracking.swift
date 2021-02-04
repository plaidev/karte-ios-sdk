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

extension UIGestureRecognizer {
    // swiftlint:disable:next type_name
    class RE {
        static let shared = RE()
        lazy var regex: NSRegularExpression? = try? NSRegularExpression(pattern: "<\\(action=(.+?),", options: [])

        deinit {
        }

        func firstMatch(in string: String) -> NSTextCheckingResult? {
            regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
        }
    }

    class func krt_vt_swizzleGestureRecognizerMethods() {
        exchangeInstanceMethod(
            cls: self,
            from: NSSelectorFromString("setState:"),
            to: #selector(krt_vt_setState(_:))
        )
    }

    @objc
    private func krt_vt_setState(_ state: UIGestureRecognizer.State) {
        if state == .recognized || state == .changed || state == .ended {
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            if let match = RE.shared.firstMatch(in: description) {
                let range = match.range(at: 1)
                let action = UIKitAction(
                    (description as NSString).substring(with: range),
                    view: view,
                    viewController: viewController,
                    targetText: Inspector.inspectText(with: view)
                )
                VisualTrackingManager.shared.dispatch(action: action)
            }
        }

        krt_vt_setState(state)
    }
}
