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

internal class UIViewControllerProxy: NSObject {
    static let shared = UIViewControllerProxy()

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(InAppMessaging.self)
            .add(UIViewControllerProxy.self)
    }
    private let cls = UIViewController.self

    private let presentViewControllerSelector = #selector(UIViewController.present(_:animated:completion:))
    private let dismissViewControllerSelector = #selector(UIViewController.dismiss(animated:completion:))
    private let viewDidAppearSelector = #selector(UIViewController.viewDidAppear(_:))

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        let presentViewControllerBlock: @convention(block) (Any, UIViewController, Bool, (() -> Void)?) -> Void = presentViewController
        scope.swizzle(
            cls: cls,
            name: presentViewControllerSelector,
            imp: imp_implementationWithBlock(presentViewControllerBlock)
        )

        let dismissViewControllerBlock: @convention(block) (Any, Bool, (() -> Void)?) -> Void = dismissViewController
        scope.swizzle(
            cls: cls,
            name: dismissViewControllerSelector,
            imp: imp_implementationWithBlock(dismissViewControllerBlock)
        )

        let viewDidAppearBlock: @convention(block) (Any, Bool) -> Void = viewDidAppear
        scope.swizzle(
            cls: cls,
            name: viewDidAppearSelector,
            imp: imp_implementationWithBlock(viewDidAppearBlock)
        )

        Logger.debug(tag: .inAppMessaging, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        Logger.debug(tag: .inAppMessaging, message: "\(className) removed method swizzling.")
    }
}

extension UIViewControllerProxy {

    func presentViewController(receiver: Any, viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UIViewController else {
            return
        }

        let window = receiver.view.window
        let process = InAppMessaging.shared.retrieveProcess(window: window)
        process?.presentViewController(viewController, in: window)

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: presentViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIViewController, Bool, (() -> Void)?) -> Void).self
        )
        originalFunction(receiver, presentViewControllerSelector, viewController, animated, completion)
    }

    func dismissViewController(receiver: Any, animated: Bool, completion: (() -> Void)?) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UIViewController else {
            return
        }

        var viewController = receiver
        while let tempViewController = viewController.presentedViewController {
            viewController = tempViewController
        }

        let window = receiver.view.window
        let process = InAppMessaging.shared.retrieveProcess(window: window)
        process?.dismissViewController(viewController, in: window)

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: dismissViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Bool, (() -> Void)?) -> Void).self
        )
        originalFunction(receiver, dismissViewControllerSelector, animated, completion)
    }

    func viewDidAppear(receiver: Any, animated: Bool) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UIViewController else {
            return
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: viewDidAppearSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Bool) -> Void).self
        )
        originalFunction(receiver, viewDidAppearSelector, animated)

        guard let window = receiver.view?.window else {
            Logger.warn(tag: .inAppMessaging, message: "The view is nil and the window not found")
            return
        }
        let process = InAppMessaging.shared.retrieveProcess(window: window)
        process?.viewDidAppearFromViewController(receiver)
    }
}
