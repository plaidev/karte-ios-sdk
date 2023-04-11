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
import KarteCore
import UIKit

internal class IAMProxy: NSObject {
    static let shared = IAMProxy()

    // swiftlint:disable:next identifier_name
    private let applicationSupportedInterfaceOrientationsForWindowSelector = #selector(UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:))

    private let scope = SafeSwizzler.scope { builder in
        builder
            .add(InAppMessaging.self)
            .add(IAMProxy.self)
    }
    private var didSwizzleMethods = false

    private lazy var className: String = {
        String(describing: type(of: self))
    }()

    private override init() {
        super.init()
    }

    func swizzleMethods() {
        if didSwizzleMethods {
            return
        }

        swizzleAppDelegateMethods()
        didSwizzleMethods = true

        Logger.debug(tag: .inAppMessaging, message: "\(className) executed method swizzling.")
    }

    func unswizzleMethods() {
        scope.unswizzle()
        didSwizzleMethods = false
        Logger.debug(tag: .inAppMessaging, message: "\(className) removed method swizzling.")
    }

    private func swizzleAppDelegateMethods() {
        guard let delegate = UIApplication.shared.delegate else {
            return
        }

        if delegate.responds(to: applicationSupportedInterfaceOrientationsForWindowSelector) {
            let block: @convention(block) (Any, UIApplication, UIWindow?) -> UIInterfaceOrientationMask = applicationSupportedInterfaceOrientationsForWindow
            let imp = imp_implementationWithBlock(block)

            scope.swizzle(
                cls: type(of: delegate).self,
                name: applicationSupportedInterfaceOrientationsForWindowSelector,
                imp: imp
            )
        }
    }

    deinit {
    }
}

extension IAMProxy {
    private func applicationSupportedInterfaceOrientationsForWindow(receiver: Any, app: UIApplication, window: UIWindow?) -> UIInterfaceOrientationMask {
        Logger.debug(tag: .inAppMessaging, message: "Invoked \(className).\(#function)")

        if let window = window, window.isKind(of: IAMWindow.self) {
            return .all
        }

        guard let delegate = UIApplication.shared.delegate, delegate.responds(to: applicationSupportedInterfaceOrientationsForWindowSelector) else {
            return .all
        }

        guard let originalImplementation = scope.originalImplementation(
            cls: type(of: delegate).self,
            name: applicationSupportedInterfaceOrientationsForWindowSelector
        ) else {
            return .all
        }

        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIApplication, UIWindow?) -> UIInterfaceOrientationMask).self
        )
        return originalFunction(receiver, applicationSupportedInterfaceOrientationsForWindowSelector, app, window)
    }
}
