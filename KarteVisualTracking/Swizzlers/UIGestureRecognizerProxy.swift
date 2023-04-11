//
//  Copyright 2023 PLAID, Inc.
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

import Foundation
import UIKit
import KarteUtilities
import KarteCore

internal class UIGestureRecognizerProxy: NSObject {
    static let shared = UIGestureRecognizerProxy()

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(VisualTracking.self)
            .add(UIGestureRecognizerProxy.self)
    }
    private let cls = UIGestureRecognizer.self

    private let setStateSelector = NSSelectorFromString("setState:")

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        let block: @convention(block) (Any, UIGestureRecognizer.State) -> Void = setState
        scope.swizzle(
            cls: cls,
            name: setStateSelector,
            imp: imp_implementationWithBlock(block)
        )

        Logger.debug(tag: .visualTracking, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        Logger.debug(tag: .visualTracking, message: "\(className) removed method swizzling.")
    }
}

extension UIGestureRecognizerProxy {
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

    func setState(receiver: Any, state: UIGestureRecognizer.State) {
        Logger.debug(tag: .visualTracking, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UIGestureRecognizer else {
            return
        }

        if state == .recognized || state == .changed || state == .ended {
            let view = receiver.view
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            if let match = RE.shared.firstMatch(in: description) {
                let range = match.range(at: 1)
                let appropriateView = UIKitAction.AppropriateViewDetector(view: view)?.detect()
                let actionId = UIKitAction.actionId(view: appropriateView)
                let action = UIKitAction(
                    (description as NSString).substring(with: range),
                    view: appropriateView,
                    viewController: viewController,
                    targetText: Inspector.inspectText(with: appropriateView),
                    actionId: actionId
                )
                VisualTrackingManager.shared.dispatch(action: action)
            }
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: setStateSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIGestureRecognizer.State) -> Void).self
        )
        originalFunction(receiver, setStateSelector, state)
    }
}
