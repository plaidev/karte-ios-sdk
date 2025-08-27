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
import WebKit

internal protocol IAMWebViewDelegate: AnyObject {
    func showInAppMessagingWebView(_ webView: IAMWebView) -> Bool
    func hideInAppMessagingWebView(_ webView: IAMWebView) -> Bool
    func inAppMessagingWebView(_ webView: IAMWebView, shouldOpenURL url: URL) -> Bool
}

internal class IAMWebView: WKWebView {
    var sceneId: SceneId
    var contentUrl: URL
    weak var delegate: IAMWebViewDelegate?

    private var responses: [[String: JSONValue]] = []
    private var views: [[String: JSONValue]] = []
    private var state: IAMState = .waiting

    init(sceneId: SceneId, configuration: WKWebViewConfiguration, url: URL) {
        self.sceneId = sceneId
        self.contentUrl = url

        super.init(frame: .zero, configuration: configuration)
        self.backgroundColor = .clear
        self.isOpaque = false
        self.isHidden = true
        self.navigationDelegate = self
        self.uiDelegate = self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.isScrollEnabled = true
        self.scrollView.bounces = false

        self.scrollView.contentInsetAdjustmentBehavior = .never
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        Logger.verbose(tag: .inAppMessaging, message: "In-app messaging view did move to superview.")
        super.didMoveToSuperview()

        if bindForWindowIfNeeded() {
            return
        }

        loadRequestIfNeeded()
        observeNotifications()
    }

    override func removeFromSuperview() {
        Logger.verbose(tag: .inAppMessaging, message: "In-app messaging view remove from subview.")
        unobserveNotifications()

        if state != .ready {
            self.state = .waiting
            self.responses.removeAll()
            self.views.removeAll()
        }

        super.removeFromSuperview()
    }

    func handle(response: [String: JSONValue]) {
        switch state {
        case .waiting:
            responses.append(response)
            loadRequestIfNeeded()

        case .loading:
            responses.append(response)

        case .ready:
            guard let value = base64EncodedString(response: response) else {
                return
            }

            let script = "tracker.handleResponseData('\(value)')"
            evaluateJavaScript(script, completionHandler: nil)

            let description = (response.jsonArray(forKey: "messages") ?? []).dictionaries.map { message in
                return ["action": [
                    "_id": message.string(forKeyPath: "action._id") ?? "",
                    "shorten_id": message.string(forKeyPath: "action.shorten_id") ?? "",
                    "campaign_id": message.string(forKeyPath: "campaign._id")
                ]]
            }.description

            Logger.verbose(tag: .inAppMessaging, message: "Evaluate tracker.handleResponseData(), messages: \(description)")
        }
    }

    func handleChangePv() {
        evaluateJavaScript("tracker.handleChangePv()", completionHandler: nil)
        Logger.verbose(tag: .inAppMessaging, message: "Evaluate handleChangePv()")
    }

    func handleView(values: [String: JSONValue]) {
        switch state {
        case .waiting:
            views.append(values)
            loadRequestIfNeeded()

        case .loading:
            views.append(values)

        case .ready:
            let viewName = convertStringOrUndefined(values.string(forKey: "view_name"))
            let title = convertStringOrUndefined(values.string(forKey: "title"))
            evaluateJavaScript("tracker.handleView(\(viewName),\(title))", completionHandler: nil)
            Logger.verbose(tag: .inAppMessaging, message: "Evaluate handleView(\(viewName),\(title))")
        }
    }

    func changeJavaScript(state: JsState?) {
        guard let state = state else {
            Logger.debug(tag: .inAppMessaging, message: "Js state is unknown.")
            self.state = .waiting
            return
        }

        switch state {
        case .initialized:
            Logger.debug(tag: .inAppMessaging, message: "Js state is initialized.")
            self.state = .ready

            responses.forEach { [weak self] response in
                self?.handle(response: response)
            }
            responses.removeAll()
            views.forEach { [weak self] values in
                self?.handleView(values: values)
            }
            views.removeAll()

        case .error:
            Logger.error(tag: .inAppMessaging, message: "Js state is error.")
            self.state = .waiting
        }
    }

    func changeVisibility(state: WidgetsState) {
        switch state {
        case .visible:
            show()

        case .invisible:
            hide()
        }
    }

    func openURL(_ url: URL?, isReset: Bool) {
        DispatchQueue.main.async {
            guard let url = url else {
                Logger.debug(tag: .inAppMessaging, message: "Can't open URL because URL is nil.")
                return
            }

            if isReset {
                self.reset(mode: .soft)
            }

            if let delegate = self.delegate, !delegate.inAppMessagingWebView(self, shouldOpenURL: url) {
                Logger.info(tag: .inAppMessaging, message: "SDK delegates openURL to client app. URL=\(url)")
                return
            }

            UIApplication.shared.open(url, options: [:]) { successful in
                if successful {
                    Logger.info(tag: .inAppMessaging, message: "Success to open URL: \(url)")
                } else {
                    Logger.error(tag: .inAppMessaging, message: "Failed to open URL: \(url)")
                }
            }
        }
    }

    func reset(mode: ResetMode) {
        let forceClose = mode == .hard
        evaluateJavaScript("tracker.resetPageState(\(forceClose))", completionHandler: nil)
        switch mode {
        case .soft:
            break

        case .hard:
            hide()
        }
    }

    func reload(url: URL) {
        self.state = .waiting
        self.contentUrl = url
        loadRequestIfNeeded()
    }

    func bindForWindowIfNeeded() -> Bool {
        if superview != nil {
            return false
        }

        if let window = sceneId.windows.first {
            return bindFor(window: window)
        } else {
            return false
        }
    }

    deinit {
    }
}

extension IAMWebView {
    private func base64EncodedString(response: [String: JSONValue]) -> String? {
        guard let data = try? createJSONEncoder().encode(response) else {
            Logger.error(tag: .inAppMessaging, message: "Failed to construct JSON.")
            return nil
        }
        return data.base64EncodedString(options: .endLineWithLineFeed)
    }

    private func convertStringOrUndefined(_ string: String?) -> String {
        if let string = string {
            return "'\(string)'"
        }
        return "undefined"
    }

    private func bindFor(window: UIWindow) -> Bool {
        if superview != nil {
            return false
        }

        self.isHidden = true
        window.addSubview(self)

        window.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        window.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        window.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        window.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        return true
    }

    private func loadRequestIfNeeded() {
        if state == .waiting && UIApplication.shared.applicationState != .background {
            loadRequest()
        }
    }

    private func loadRequest() {
        self.state = .loading
        load(URLRequest(url: contentUrl))
    }

    private func canReset(navigationAction: WKNavigationAction) -> Bool {
        if let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame {
            return true
        }
        return false
    }

    private func show() {
        guard let delegate = delegate, delegate.showInAppMessagingWebView(self) else {
            return
        }
        self.isHidden = false
    }

    private func hide() {
        guard let delegate = delegate, delegate.hideInAppMessagingWebView(self) else {
            return
        }
        self.isHidden = true
    }
}

extension IAMWebView {
    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeKeyboardWillHideNotification(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func unobserveNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func observeKeyboardWillHideNotification(_ notification: Notification) {
        guard let window = window, let userInfo = notification.userInfo, window.isKind(of: IAMWindow.self) else {
            return
        }

        guard let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }

        func _animations() {
            self.scrollView.contentOffset = .zero
        }
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: _animations, completion: nil)
    }
}

extension IAMWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse, 200..<300 ~= response.statusCode {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        let navigationActionPolicy: WKNavigationActionPolicy
        defer {
            decisionHandler(navigationActionPolicy)
        }

        guard let url = navigationAction.request.url else {
            navigationActionPolicy = .cancel
            return
        }

        switch navigationAction.navigationType {
        case .linkActivated:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is LinkActivated.")
            openURL(url, isReset: canReset(navigationAction: navigationAction))
            navigationActionPolicy = .cancel

        case .backForward:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is BackForward.")
            navigationActionPolicy = .cancel

        case .formResubmitted:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is FormResubmitted.")
            navigationActionPolicy = .cancel

        case .formSubmitted:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is FormSubmitted.")
            navigationActionPolicy = .cancel

        case .reload:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is Reload.")
            navigationActionPolicy = .cancel

        case .other:
            Logger.verbose(tag: .inAppMessaging, message: "WebView navigation type is Other.")
            guard contentUrl.baseURL?.host != url.host else {
                navigationActionPolicy = .allow
                return
            }
            guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
                navigationActionPolicy = .allow
                return
            }
            openURL(url, isReset: canReset(navigationAction: navigationAction))
            navigationActionPolicy = .cancel

        @unknown default:
            navigationActionPolicy = .allow
        }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Logger.verbose(tag: .inAppMessaging, message: "WebView did commit navigation.")
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.verbose(tag: .inAppMessaging, message: "WebView did finish navigation.")
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.error(tag: .inAppMessaging, message: "WebView did fail navigation: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.error(tag: .inAppMessaging, message: "WebView did fail provisional navigation: \(error.localizedDescription)")
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Logger.verbose(tag: .inAppMessaging, message: "WebView web content process did terminate.")
        self.state = .waiting
        hide()
    }
}

extension IAMWebView: WKUIDelegate {
    func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping @MainActor (UIContextMenuConfiguration?) -> Void) {
        let configuration = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: nil
        )
        completionHandler(configuration)
    }
}

extension IAMWebView {
    enum ResetMode {
        case soft
        case hard
    }
}
