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

internal class UIApplicationProxy: NSObject {
    static let shared = UIApplicationProxy()

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(VisualTracking.self)
            .add(UIApplicationProxy.self)
    }
    private let cls = UIApplication.self

    private let sendActionSelector = #selector(UIApplication.sendAction(_:to:from:for:))
    private let sendEventSelector = #selector(UIApplication.sendEvent(_:))

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        let sendActionBlock: @convention(block) (Any, Selector, Any?, Any?, UIEvent?) -> Bool = sendAction
        scope.swizzle(
            cls: cls,
            name: sendActionSelector,
            imp: imp_implementationWithBlock(sendActionBlock)
        )

        let sendEventBlock: @convention(block) (Any, UIEvent) -> Void = sendEvent
        scope.swizzle(
            cls: cls,
            name: sendEventSelector,
            imp: imp_implementationWithBlock(sendEventBlock)
        )

        Logger.debug(tag: .visualTracking, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        Logger.debug(tag: .visualTracking, message: "\(className) removed method swizzling.")
    }
}

extension UIApplicationProxy {

    func sendAction(receiver: Any, action: Selector, to target: Any?, from sender: Any?, for event: UIEvent?) -> Bool {
        Logger.debug(tag: .visualTracking, message: "Invoked \(className).\(#function)")

        if let view = target as? UIView, event != nil {
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            let appropriateView = UIKitAction.AppropriateViewDetector(view: view)?.detect()
            let action = UIKitAction(
                NSStringFromSelector(action),
                view: view,
                viewController: viewController,
                targetText: Inspector.inspectText(with: sender),
                actionId: UIKitAction.actionId(view: appropriateView)
            )
            VisualTrackingManager.shared.dispatch(action: action)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: sendActionSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Selector, Any?, Any?, UIEvent?) -> Bool).self)
        return originalFunction(receiver, sendActionSelector, action, target, sender, event)
    }

    func sendEvent(receiver: Any, event: UIEvent) {
        Logger.debug(tag: .visualTracking, message: "Invoked \(className).\(#function)")

        let touches = event.allTouches ?? []
        for touch in touches where touch.phase == .ended {
            let view = touch.view
            let viewController = UIResponder.krt_vt_retrieveViewController(for: view)
            let appropriateView = UIKitAction.AppropriateViewDetector(view: view)?.detect()
            let actionId = UIKitAction.actionId(view: appropriateView)
            let action = UIKitAction(
                "touch",
                view: appropriateView,
                viewController: viewController,
                targetText: Inspector.inspectText(with: view),
                actionId: actionId
            )
            VisualTrackingManager.shared.dispatch(action: action)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: sendEventSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIEvent) -> Void).self
        )
        originalFunction(receiver, sendEventSelector, event)
    }
}
