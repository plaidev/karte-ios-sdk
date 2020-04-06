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

extension UIApplication {
    class func krt_vt_swizzleApplicationMethods() {
        exchangeInstanceMethod(
            from: #selector(sendAction(_:to:from:for:)),
            to: #selector(krt_vt_sendAction(_:to:from:for:))
        )
        exchangeInstanceMethod(
            from: #selector(sendEvent(_:)),
            to: #selector(krt_vt_sendEvent(_:))
        )
    }

    @objc
    private func krt_vt_sendAction(_ action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        if let view = target as? UIView, event != nil {
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            let action = Action(
                NSStringFromSelector(action),
                view: view,
                viewController: viewController,
                targetText: Inspector.inspectText(with: sender)
            )
            VisualTrackingManager.shared.dispatch(action: action)
        }
        return krt_vt_sendAction(action, to: target, from: sender, for: event)
    }

    @objc
    private func krt_vt_sendEvent(_ event: UIEvent) {
        let touches = event.allTouches ?? []
        for touch in touches where touch.phase == .ended {
            let view = touch.view
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            let action = Action(
                "touch",
                view: view,
                viewController: viewController,
                targetText: Inspector.inspectText(with: view)
            )
            VisualTrackingManager.shared.dispatch(action: action)
        }
        krt_vt_sendEvent(event)
    }
}
