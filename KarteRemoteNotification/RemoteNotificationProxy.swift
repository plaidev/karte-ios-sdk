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

import KarteCore
import KarteUtilities
import ObjectiveC
import UIKit

private var userNotificationObserverContext: UInt8 = 0

internal class RemoteNotificationProxy: NSObject {
    static let shared = RemoteNotificationProxy()

    var isEnabled = true

    // swiftlint:disable identifier_name
    private let applicationDidReceiveRemoteNotificationFetchCompletionHandlerSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
    private let userNotificationCenterDidReceiveNotificationResponseWithCompletionHandlerSelectorString = "userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"
    // swiftlint:enable identifier_name

    private let label = "remote_notification"

    private var interceptorId: String?
    private var didSwizzleMethods = false
    private weak var currentUserNotificationCenterDelegate: AnyObject?

    // KVO object
    private var userNotificationCenter: AnyObject?

    var canSwizzleMethods: Bool {
        guard NSClassFromString("FIRMessaging") != nil else {
            Logger.debug(tag: .notification, message: "Firebase messaging framework is not linked.")
            return false
        }
        guard isEnabled else {
            Logger.info(tag: .notification, message: "Auto measurement is disabled.")
            return false
        }
        return true
    }

    func swizzleMethods() {
        if !canSwizzleMethods || didSwizzleMethods {
            return
        }

        swizzleAppDelegateMethods()
        swizzleUserNotificationCenterDelegateMethods()

        didSwizzleMethods = true
    }

    func unswizzleMethods() {
        removeUserNotificationCenterDelegateObserver()
        unregisterAppDelegateInterceptorIfNeeded()

        Swizzler.shared.unswizzle(label: label)
        didSwizzleMethods = false
    }

    private func swizzleAppDelegateMethods() {
        guard let delegate = UIApplication.shared.delegate else {
            return
        }

        // for Firebase SDK v6.x
        if let interceptorId = registerAppDelegateInterceptorIfNeeded() {
            Logger.debug(tag: .notification, message: "Register app delegate interceptor: \(interceptorId)")
            self.interceptorId = interceptorId
        } else if delegate.responds(to: applicationDidReceiveRemoteNotificationFetchCompletionHandlerSelector) {
            let block: @convention(block) (Any, UIApplication, [AnyHashable: Any], @escaping (UIBackgroundFetchResult) -> Void) -> Void = applicationDidReceiveRemoteNotificationFetchCompletionHandler
            let imp = imp_implementationWithBlock(block)

            Swizzler.shared.swizzle(
                label: label,
                cls: type(of: delegate).self,
                name: applicationDidReceiveRemoteNotificationFetchCompletionHandlerSelector,
                imp: imp,
                proto: UIApplicationDelegate.self
            )
        }
    }

    private func registerAppDelegateInterceptorIfNeeded() -> String? {
        guard let cls = NSClassFromString("GULAppDelegateSwizzler") else {
            return nil
        }

        let sel = NSSelectorFromString("isAppDelegateProxyEnabled")
        guard let method = class_getClassMethod(cls, sel) else {
            return nil
        }
        let imp = method_getImplementation(method)
        let originalFunction = unsafeBitCast(
            imp,
            to: (@convention(c) (Any, Selector) -> Bool).self
        )
        guard originalFunction(cls, sel) else {
            return nil
        }

        guard let interceptorId: String = AnyObjectHelper.invoke(from: cls, methodName: "registerAppDelegateInterceptor:", with: self) else {
            return nil
        }

        return interceptorId
    }

    private func unregisterAppDelegateInterceptorIfNeeded() {
        guard let interceptorId = self.interceptorId, let cls = NSClassFromString("GULAppDelegateSwizzler") else {
            return
        }

        let _: Void? = AnyObjectHelper.invoke(from: cls, methodName: "unregisterAppDelegateInterceptorWithID:", with: interceptorId)
    }

    private func swizzleUserNotificationCenterDelegateMethods() {
        guard let userNotificationCenterClass = NSClassFromString("UNUserNotificationCenter") else {
            return
        }

        let userNotificationCenter = AnyObjectHelper.propertyValue(
            from: userNotificationCenterClass,
            propertyName: "currentNotificationCenter",
            cls: userNotificationCenterClass
        )

        if let userNotificationCenter = userNotificationCenter {
            listenForDelegateChangesInUserNotificationCenter(userNotificationCenter)
        }
    }

    private func listenForDelegateChangesInUserNotificationCenter(_ userNotificationCenter: AnyObject) {
        guard AnyObjectHelper.isKind(of: "UNUserNotificationCenter", object: userNotificationCenter) else {
            return
        }

        if let delegate = AnyObjectHelper.propertyValue(from: userNotificationCenter, propertyName: "delegate", cls: nil) {
            swizzleUserNotificationCenterDelegate(delegate)
        }

        addUserNotificationCenterDelegateObserver(userNotificationCenter: userNotificationCenter)
    }

    private func swizzleUserNotificationCenterDelegate(_ delegate: AnyObject) {
        guard !AnyObjectHelper.equals(currentUserNotificationCenterDelegate, delegate) else {
            return
        }

        guard let userNotificationCenterDelegate = NSProtocolFromString("UNUserNotificationCenterDelegate") else {
            return
        }

        let sel = NSSelectorFromString(userNotificationCenterDidReceiveNotificationResponseWithCompletionHandlerSelectorString)
        guard delegate.responds(to: sel) else {
            return
        }

        let block: @convention(block) (Any, AnyObject, AnyObject, @escaping () -> Void) -> Void = userNotificationCenterDidReceiveNotificationResponseWithCompletionHandler
        let imp = imp_implementationWithBlock(block)
        Swizzler.shared.swizzle(
            label: label,
            cls: type(of: delegate).self,
            name: sel,
            imp: imp,
            proto: userNotificationCenterDelegate
        )

        self.currentUserNotificationCenterDelegate = delegate
    }

    private func unswizzleUserNotificationCenterDelegate(_ delegate: AnyObject) {
        guard AnyObjectHelper.equals(currentUserNotificationCenterDelegate, delegate) else {
            return
        }

        guard let userNotificationCenterDelegate = currentUserNotificationCenterDelegate else {
            return
        }

        let sel = NSSelectorFromString(userNotificationCenterDidReceiveNotificationResponseWithCompletionHandlerSelectorString)
        Swizzler.shared.unswizzle(label: label, cls: type(of: userNotificationCenterDelegate).self, name: sel)

        self.currentUserNotificationCenterDelegate = nil
    }

    deinit {
    }
}

// MARK: - KVO
extension RemoteNotificationProxy {
    private func addUserNotificationCenterDelegateObserver(userNotificationCenter: AnyObject) {
        removeUserNotificationCenterDelegateObserver()

        let options: NSKeyValueObservingOptions = [.new, .old]
        userNotificationCenter.addObserver(self, forKeyPath: "delegate", options: options, context: &userNotificationObserverContext)

        self.userNotificationCenter = userNotificationCenter
    }

    private func removeUserNotificationCenterDelegateObserver() {
        guard let userNotificationCenter = userNotificationCenter else {
            return
        }

        userNotificationCenter.removeObserver(self, forKeyPath: "delegate", context: &userNotificationObserverContext)
        self.userNotificationCenter = nil
    }

    // swiftlint:disable:next block_based_kvo discouraged_optional_collection
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let context = context, context == &userNotificationObserverContext {
            guard keyPath == "delegate" else {
                return
            }
            if let oldDelegate = change?[.oldKey] {
                unswizzleUserNotificationCenterDelegate(oldDelegate as AnyObject)
            }
            if let newDelegate = change?[.newKey] {
                swizzleUserNotificationCenterDelegate(newDelegate as AnyObject)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Swizzled implementations
extension RemoteNotificationProxy {
    private func applicationDidReceiveRemoteNotificationFetchCompletionHandler(_ receiver: Any, app: UIApplication, userInfo: [AnyHashable: Any], handler: @escaping (UIBackgroundFetchResult) -> Void) {
        application(app, didReceiveRemoteNotification: userInfo) { _ in }

        let originalSelector = applicationDidReceiveRemoteNotificationFetchCompletionHandlerSelector
        guard let originalImplementation = Swizzler.shared.originalImplementation(forName: originalSelector) else {
            handler(.newData)
            return
        }

        let originalFunction = unsafeBitCast(
            originalImplementation,
            to: (@convention(c) (Any, Selector, UIApplication, [AnyHashable: Any], @escaping (UIBackgroundFetchResult) -> Void) -> Void).self
        )
        originalFunction(receiver, originalSelector, app, userInfo, handler)
    }

    private func userNotificationCenterDidReceiveNotificationResponseWithCompletionHandler(_ receiver: Any, center: AnyObject, response: AnyObject, handler: @escaping () -> Void) {
        func callOriginalFunction() {
            let originalSelector = NSSelectorFromString(userNotificationCenterDidReceiveNotificationResponseWithCompletionHandlerSelectorString)
            guard let originalImplementation = Swizzler.shared.originalImplementation(forName: originalSelector) else {
                return
            }

            let originalFunction = unsafeBitCast(
                originalImplementation,
                to: (@convention(c) (Any, Selector, AnyObject, AnyObject, @escaping () -> Void) -> Void).self
            )
            originalFunction(receiver, originalSelector, center, response, handler)
        }

        guard AnyObjectHelper.isKind(of: "UNNotificationResponse", object: response) else {
            callOriginalFunction()
            return
        }

        guard let notification = AnyObjectHelper.propertyValue(from: response, propertyName: "notification", cls: NSClassFromString("UNNotification")) else {
            callOriginalFunction()
            return
        }

        guard let request = AnyObjectHelper.propertyValue(from: notification, propertyName: "request", cls: NSClassFromString("UNNotificationRequest")) else {
            callOriginalFunction()
            return
        }

        guard let content = AnyObjectHelper.propertyValue(from: request, propertyName: "content", cls: NSClassFromString("UNNotificationContent")) else {
            callOriginalFunction()
            return
        }

        guard let userInfo = AnyObjectHelper.propertyValue(from: content, propertyName: "userInfo", cls: NSDictionary.self) as? [AnyHashable: Any] else {
            callOriginalFunction()
            return
        }

        Measurement.measure(userInfo: userInfo)
        callOriginalFunction()
    }
}

// MARK: Invoke from Firebase
extension RemoteNotificationProxy: UIApplicationDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .inactive {
            Measurement.measure(userInfo: userInfo)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive {
            Measurement.measure(userInfo: userInfo)
        }
    }
}
