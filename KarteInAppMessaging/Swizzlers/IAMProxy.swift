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

internal class IAMProxy: NSObject {
    static let shared = IAMProxy()

    // swiftlint:disable:next identifier_name
    private let applicationSupportedInterfaceOrientationsForWindowSelector = #selector(UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:))

    private let label = "in_app_messaging"
    private var isSwizzled = false

    func swizzleMethods() {
        if isSwizzled {
            return
        }

        swizzleAppDelegateMethods()
        isSwizzled = true
    }

    func unswizzleMethods() {
        Swizzler.shared.unswizzle(label: label)
        isSwizzled = false
    }

    private func swizzleAppDelegateMethods() {
        guard let delegate = UIApplication.shared.delegate else {
            return
        }

        if delegate.responds(to: applicationSupportedInterfaceOrientationsForWindowSelector) {
            let block: @convention(block) (Any, UIApplication, UIWindow?) -> UIInterfaceOrientationMask = applicationSupportedInterfaceOrientationsForWindow
            let imp = imp_implementationWithBlock(block)

            Swizzler.shared.swizzle(
                label: label,
                cls: type(of: delegate).self,
                name: applicationSupportedInterfaceOrientationsForWindowSelector,
                imp: imp,
                proto: UIApplicationDelegate.self
            )
        }
    }

    deinit {
    }
}

extension IAMProxy {
    private func applicationSupportedInterfaceOrientationsForWindow(receiver: Any, app: UIApplication, window: UIWindow?) -> UIInterfaceOrientationMask {
        if let window = window, window.isKind(of: IAMWindow.self) {
            return .all
        }

        let originalSelector = applicationSupportedInterfaceOrientationsForWindowSelector
        guard let originalImplementation = Swizzler.shared.originalImplementation(forName: originalSelector) else {
            return .all
        }

        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIApplication, UIWindow?) -> UIInterfaceOrientationMask).self
        )
        return originalFunction(receiver, applicationSupportedInterfaceOrientationsForWindowSelector, app, window)
    }
}
