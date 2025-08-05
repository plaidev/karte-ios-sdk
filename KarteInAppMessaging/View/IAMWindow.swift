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
import UIKit

internal class IAMWindow: UIWindow {
    static var windowLevel: UIWindow.Level {
        UIWindow.Level(UIWindow.Level.normal.rawValue + 10)
    }

    weak var webView: IAMWebView?
    var detector = OpacityDetector()

    init?(sceneId: SceneId) {
        if #available(iOS 13.0, *) {
            guard let windowScene = WindowSceneDetector.retrieveWindowScene(from: sceneId.identifier) else {
                return nil
            }
            super.init(windowScene: windowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        initialize()
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)

        if isPresentedFileBrowser {
            return hitTestView
        }

        if isNotContainsSubviews {
            return nil
        }

        if let webView = webView, detector.detectAtPoint(point, view: webView, event: event) {
            return hitTestView
        }

        if isKeyWindow {
            let windows = WindowDetector.retrieveRelatedWindows(view: self)
            windows.first?.makeKey()
        }

        return nil
    }

    func present(webView: IAMWebView, isFocus: Bool) {
        self.webView = webView
        self.rootViewController = IAMViewController(webView: webView)
        self.isHidden = false

        if isFocus {
            makeKey()
        }
    }

    deinit {
    }
}

extension IAMWindow {
    private var isPresentedFileBrowser: Bool {
        rootViewController?.presentedViewController != nil
    }

    private var isNotContainsSubviews: Bool {
        let subviews = rootViewController?.view.subviews ?? []
        return subviews.isEmpty
    }

    private func initialize() {
        self.windowLevel = type(of: self).windowLevel
        self.backgroundColor = .clear
        self.isHidden = true
    }
}
