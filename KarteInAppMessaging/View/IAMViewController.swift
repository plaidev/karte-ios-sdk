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
import WebKit

internal class IAMViewController: UIViewController {
    var webView: WKWebView

    override var shouldAutorotate: Bool {
        behindViewController?.shouldAutorotate ?? false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let window = WindowDetector.retrieveRelatedWindows(view: view).first else {
            return UIApplication.shared.supportedInterfaceOrientations(for: nil)
        }

        guard let delegate = UIApplication.shared.delegate else {
            return UIApplication.shared.supportedInterfaceOrientations(for: window)
        }

        let windowMask: UIInterfaceOrientationMask
        if delegate.responds(to: #selector(UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:))) {
            // swiftlint:disable:next force_unwrapping
            windowMask = delegate.application!(
                UIApplication.shared,
                supportedInterfaceOrientationsFor: window
            )
        } else {
            windowMask = UIApplication.shared.supportedInterfaceOrientations(for: window)
        }

        let viewControllerMask = behindViewController?.supportedInterfaceOrientations ?? .all
        return windowMask.intersection(viewControllerMask)
    }

    override var childForStatusBarStyle: UIViewController? {
        behindViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        behindViewController
    }

    init(webView: WKWebView) {
        self.webView = webView
        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.isOpaque = false
        view.addSubview(webView)

        view.topAnchor.constraint(equalTo: webView.topAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: webView.leftAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: webView.bottomAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: webView.rightAnchor, constant: 0).isActive = true
    }

    deinit {
    }
}

extension IAMViewController {
    private var behindViewController: UIViewController? {
        guard let window = WindowDetector.retrieveRelatedWindows(view: view).first else {
            return nil
        }
        guard window.windowLevel.rawValue < IAMWindow.windowLevel.rawValue else {
            return nil
        }
        guard var behindViewController = window.rootViewController else {
            return nil
        }

        while let viewController = behindViewController.presentedViewController {
            let style = viewController.modalPresentationStyle
            switch style {
            case .formSheet, .pageSheet, .overCurrentContext, .overFullScreen, .popover:
                break

            default:
                behindViewController = viewController
            }
        }

        return behindViewController
    }
}
