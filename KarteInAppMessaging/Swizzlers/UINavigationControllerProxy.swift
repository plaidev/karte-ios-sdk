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

internal class UINavigationControllerProxy: NSObject {
    static let shared = UINavigationControllerProxy()

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(InAppMessaging.self)
            .add(UINavigationControllerProxy.self)
    }
    private let cls = UINavigationController.self

    private let setViewControllersSelector = #selector(UINavigationController.setViewControllers(_:animated:))
    private let pushViewControllerSelector = #selector(UINavigationController.pushViewController(_:animated:))
    private let popViewControllerSelector = #selector(UINavigationController.popViewController(animated:))
    private let popToViewControllerSelector = #selector(UINavigationController.popToViewController(_:animated:))
    private let popToRootViewControllerSelector = #selector(UINavigationController.popToRootViewController(animated:))

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        let setViewControllersBlock: @convention(block) (Any, [UIViewController], Bool) -> Void = setViewControllers
        scope.swizzle(
            cls: cls,
            name: setViewControllersSelector,
            imp: imp_implementationWithBlock(setViewControllersBlock)
        )

        let pushViewControllerBlock: @convention(block) (Any, UIViewController, Bool) -> Void = pushViewController
        scope.swizzle(
            cls: cls,
            name: pushViewControllerSelector,
            imp: imp_implementationWithBlock(pushViewControllerBlock)
        )

        let popViewControllerBlock: @convention(block) (Any, Bool) -> UIViewController? = popViewController
        scope.swizzle(
            cls: cls,
            name: popViewControllerSelector,
            imp: imp_implementationWithBlock(popViewControllerBlock)
        )

        let popToViewControllerBlock: @convention(block) (Any, UIViewController, Bool) -> [UIViewController]? = popToViewController
        scope.swizzle(
            cls: cls,
            name: popToViewControllerSelector,
            imp: imp_implementationWithBlock(popToViewControllerBlock)
        )

        let popToRootViewControllerBlock: @convention(block) (Any, Bool) -> [UIViewController]? = popToRootViewController
        scope.swizzle(
            cls: cls,
            name: popToRootViewControllerSelector,
            imp: imp_implementationWithBlock(popToRootViewControllerBlock)
        )

        Logger.debug(tag: .inAppMessaging, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        Logger.debug(tag: .inAppMessaging, message: "\(className) removed method swizzling.")
    }
}

extension UINavigationControllerProxy {

    func setViewControllers(receiver: Any, viewControllers: [UIViewController], animated: Bool) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UINavigationController else {
            return
        }

        if let window = receiver.view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.pushViewController(viewControllers.last, to: receiver, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: setViewControllersSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, [UIViewController], Bool) -> Void).self
        )
        originalFunction(receiver, setViewControllersSelector, viewControllers, animated)
    }

    func pushViewController(receiver: Any, viewController: UIViewController, animated: Bool) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UINavigationController else {
            return
        }

        if let window = receiver.view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.pushViewController(viewController, to: receiver, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: pushViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIViewController, Bool) -> Void).self
        )
        originalFunction(receiver, pushViewControllerSelector, viewController, animated)
    }

    func popViewController(receiver: Any, animated: Bool) -> UIViewController? {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UINavigationController else {
            return nil
        }

        if let window = receiver.view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.popViewController(receiver.visibleViewController, from: receiver, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: popViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Bool) -> UIViewController?).self
        )
        return originalFunction(receiver, popViewControllerSelector, animated)
    }

    func popToViewController(receiver: Any, viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UINavigationController else {
            return nil
        }

        if let window = receiver.view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.popViewController(receiver.visibleViewController, from: receiver, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: popToViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIViewController, Bool) -> [UIViewController]?).self
        )
        return originalFunction(receiver, popToViewControllerSelector, viewController, animated)
    }

    func popToRootViewController(receiver: Any, animated: Bool) -> [UIViewController]? {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UINavigationController else {
            return nil
        }

        if let window = receiver.view.window {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.popViewController(receiver.visibleViewController, from: receiver, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: popToRootViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Bool) -> [UIViewController]?).self
        )
        return originalFunction(receiver, popToRootViewControllerSelector, animated)
    }
}
