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
import KarteDetectors
import UIKit
import WebKit

/// アプリ内メッセージの管理を行うクラスです。
@objc(KRTInAppMessaging)
public class InAppMessaging: NSObject {
    /// 共有インスタンスを返します。
    @objc public static let shared = InAppMessaging()

    /// アプリ内メッセージで発生するイベント等を委譲するためのデリゲートインスタンスを取得・設定します。
    @objc public weak var delegate: InAppMessagingDelegate?

    /// アプリ内メッセージの表示有無を返します。
    ///
    /// アプリ内メッセージが表示中の場合は `true` を返し、表示されていない場合は `false` を返します。
    @objc public var isPresenting: Bool {
        let processes = pool.processes.filter { $0.isPresenting }
        return !processes.isEmpty
    }

    private let pool = IAMProcessPool()
    var isSuppressed = false
    var app: KarteApp?

    override private init() {
        super.init()
        observeNotifications()
    }

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    /// 指定したViewに関連するシーンにおけるアプリ内メッセージの表示有無を返します。
    ///
    /// iOS12以下では、`isPresenting` と同様の挙動になります。
    ///
    /// - Parameter view: シーンに関連するView
    /// - Returns: アプリ内メッセージが表示中の場合は `true` を返し、表示されていない場合は `false` を返します。
    @objc
    public func isPresenting(view: UIView) -> Bool {
        if let process = pool.retrieveProcess(view: view) {
            return process.isPresenting
        }
        return false
    }

    /// 現在表示中の全てのアプリ内メッセージを非表示にします。
    @objc
    public func dismiss() {
        pool.processes.forEach { $0.dismiss() }
    }

    /// 指定したViewに関連するシーンに表示されているアプリ内メッセージを非表示にします。
    ///
    /// iOS12以下では、 `dismiss()` と同様の挙動になります。
    ///
    /// - Parameter view: シーンに関連するView
    @objc
    public func dismiss(view: UIView) {
        pool.retrieveProcess(view: view)?.dismiss()
    }

    /// アプリ内メッセージの表示を抑制します。
    ///
    /// なお既に表示されているアプリ内メッセージは、メソッドの呼び出しと同時に非表示となります。
    @objc
    public func suppress() {
        self.isSuppressed = true
        dismiss()
    }

    /// 指定したViewに関連するシーンにおけるアプリ内メッセージの表示を抑制します。
    ///
    /// なお既に表示されているアプリ内メッセージは、メソッドの呼び出しと同時に非表示となります。
    ///
    /// - Parameter view: シーンに関連するView
    @objc
    public func suppress(view: UIView) {
        if let process = pool.retrieveProcess(view: view) {
            process.isSuppressed = true
            process.dismiss()
        }
    }

    /// アプリ内メッセージの表示抑制状態を解除します。
    @objc
    public func unsuppress() {
        self.isSuppressed = false
    }

    /// 指定したViewに関連するシーンにおけるアプリ内メッセージの表示抑制状態を解除します。
    ///
    /// - Parameter view: シーンに関連するView
    @objc
    public func unsuppress(view: UIView) {
        if let process = pool.retrieveProcess(view: view) {
            process.isSuppressed = false
        }
    }

    func configure(app: KarteApp) {
        self.app = app

        app.register(module: .action(self))
        app.register(module: .user(self))

        IAMProxy.shared.swizzleMethods()
        UINavigationController.krt_swizzleNavigationTransitionMethods()
        UITabBarController.krt_swizzleTabBarTransitionMethods()
        UIViewController.krt_swizzleTransitionMethods()
        UIViewController.krt_swizzleLifecycleMethods()
    }

    func unconfigure(app: KarteApp) {
        app.unregister(module: .action(self))
        app.unregister(module: .user(self))

        IAMProxy.shared.unswizzleMethods()
    }

    func retrieveProcess(window: UIWindow?) -> IAMProcess? {
        guard let window = window else {
            return nil
        }
        return pool.retrieveProcess(view: window)
    }

    func preview(url: URL) {
        let process = pool.retrieveProcess(view: nil)
        process?.reload(url: url)
    }

    deinit {
        unobserveNotifications()
    }
}

// MARK: - Notification
extension InAppMessaging {
    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeWindowDidBecomeVisibleNotification(_:)),
            name: UIWindow.didBecomeVisibleNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeWindowDidBecomeHiddenNotification(_:)),
            name: UIWindow.didBecomeHiddenNotification,
            object: nil
        )
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(observeSceneDidDisconnectNotification(_:)),
                name: UIScene.didDisconnectNotification,
                object: nil
            )
        }
    }

    private func unobserveNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIWindow.didBecomeVisibleNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIWindow.didBecomeHiddenNotification,
            object: nil
        )
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(
                self,
                name: UIScene.didDisconnectNotification,
                object: nil
            )
        }
    }

    @objc
    private func observeWindowDidBecomeVisibleNotification(_ notification: Notification) {
        guard let window = notification.object as? UIWindow else {
            return
        }

        if window.isKind(of: IAMWindow.self), let delegate = delegate {
            var delegated = false
            if #available(iOS 13.0, *) {
                let selector = #selector(InAppMessagingDelegate.inAppMessagingWindowIsPresented(_:onScene:))
                if (delegate as AnyObject).responds(to: selector), let scene = window.windowScene {
                    delegate.inAppMessagingWindowIsPresented?(self, onScene: scene)
                    delegated = true
                }
            }
            if !delegated {
                delegate.inAppMessagingWindowIsPresented?(self)
            }
        }

        guard let app = app, pool.retrieveProcess(view: window) == nil else {
            return
        }

        let process = IAMProcess(view: window, configuration: IAMProcessConfiguration(app: app))
        pool.storeProcess(process)
    }

    @objc
    private func observeWindowDidBecomeHiddenNotification(_ notification: Notification) {
        guard let window = notification.object as? UIWindow else {
            return
        }

        if window.isKind(of: IAMWindow.self), let delegate = delegate {
            var delegated = false
            if #available(iOS 13.0, *) {
                let selector = #selector(InAppMessagingDelegate.inAppMessagingWindowIsDismissed(_:onScene:))
                if (delegate as AnyObject).responds(to: selector), let scene = window.windowScene {
                    delegate.inAppMessagingWindowIsDismissed?(self, onScene: scene)
                    delegated = true
                }
            }
            if !delegated {
                delegate.inAppMessagingWindowIsDismissed?(self)
            }
        }
    }

    @available(iOS 13.0, *)
    @objc
    private func observeSceneDidDisconnectNotification(_ notification: Notification) {
        guard let scene = notification.object as? UIScene else {
            return
        }

        let sceneId = SceneId(scene.session.persistentIdentifier)
        guard let process = pool.retrieveProcess(sceneId: sceneId) else {
            return
        }

        process.terminate()
        pool.removeProcess(sceneId: sceneId)
    }

    private func clearWkWebViewCookies() {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes: Set<String> = [WKWebsiteDataTypeCookies]
        dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            let records = records.filter { record -> Bool in
                record.displayName.contains("karte.io")
            }
            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, for: records) {}
        }
    }
}

extension InAppMessaging: Library {
    public static var name: String {
        "in_app_messaging"
    }

    public static var version: String {
        KRTInAppMessagingCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        shared.configure(app: app)
    }

    public static func unconfigure(app: KarteApp) {
        shared.unconfigure(app: app)
    }
}

extension InAppMessaging: ActionModule, UserModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public var queue: DispatchQueue? {
        .main
    }

    public func receive(response: TrackResponse.Response, request: TrackRequest) {
        var response = response

        let filter = MessageFilter.Builder()
            .add(MessagePvIdFilterRule(request: request, app: app))
            .build()
        response.messages = filter.filter(response.messages)

        if pool.canCreateProcess(sceneId: request.sceneId) {
            guard let window = WindowDetector.retrieveRelatedWindows(from: request.sceneId.identifier).first, let app = app else {
                Logger.warn(tag: .inAppMessaging, message: "Window is not found.")
                return
            }

            let process = IAMProcess(view: window, configuration: IAMProcessConfiguration(app: app))
            pool.storeProcess(process)
        }

        if let process = pool.retrieveProcess(sceneId: request.sceneId) {
            process.handle(response: response)
        }
    }

    public func reset(sceneId: SceneId) {
        if let process = pool.retrieveProcess(sceneId: sceneId) {
            process.dismiss()
        }
    }

    public func resetAll() {
        pool.processes.forEach { process in
            process.dismiss()
        }
    }

    public func renew(visitorId current: String, previous: String) {
        pool.processes.forEach { process in
            process.dismiss()
            process.reload()
        }
        clearWkWebViewCookies()
    }
}

extension Logger.Tag {
    static let inAppMessaging = Logger.Tag("IAM", version: KRTInAppMessagingCurrentLibraryVersion())
}
