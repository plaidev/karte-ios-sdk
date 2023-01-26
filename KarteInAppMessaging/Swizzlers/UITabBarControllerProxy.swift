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

internal class UITabBarControllerProxy: NSObject {
    static let shared = UITabBarControllerProxy()

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(InAppMessaging.self)
            .add(UITabBarControllerProxy.self)
    }
    private let cls = UITabBarController.self

    private let setSelectedIndexSelector = #selector(setter: UITabBarController.selectedIndex)
    private let setSelectedViewControllerSelector = #selector(setter: UITabBarController.selectedViewController)

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        let setSelectedIndexBlock: @convention(block) (Any, Int) -> Void = setSelectedIndex
        scope.swizzle(
            cls: cls,
            name: setSelectedIndexSelector,
            imp: imp_implementationWithBlock(setSelectedIndexBlock)
        )

        let setSelectedViewControllerBlock: @convention(block) (Any, UIViewController) -> Void = setSelectedViewController
        scope.swizzle(
            cls: cls,
            name: setSelectedViewControllerSelector,
            imp: imp_implementationWithBlock(setSelectedViewControllerBlock)
        )

        Logger.debug(tag: .inAppMessaging, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        Logger.debug(tag: .inAppMessaging, message: "\(className) removed method swizzling.")
    }
}

extension UITabBarControllerProxy {

    func setSelectedIndex(receiver: Any, index: Int) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UITabBarController else {
            return
        }

        if let window = receiver.view.window, let viewControllers = receiver.viewControllers {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.setSelectedViewController(viewControllers[index], in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: setSelectedIndexSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, Int) -> Void).self
        )
        originalFunction(receiver, setSelectedIndexSelector, index)
    }

    func setSelectedViewController(receiver: Any, viewController: UIViewController) {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        guard let receiver = receiver as? UITabBarController else {
            return
        }

        if let window = receiver.view.window, let viewControllers = receiver.viewControllers, viewControllers.contains(viewController) {
            let process = InAppMessaging.shared.retrieveProcess(window: window)
            process?.setSelectedViewController(viewController, in: window)
        }

        let originalImplementation = scope.originalImplementation(
            cls: cls,
            name: setSelectedViewControllerSelector
        )
        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIViewController) -> Void).self
        )
        originalFunction(receiver, setSelectedViewControllerSelector, viewController)
    }
}
