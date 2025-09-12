//
//  Copyright 2024 PLAID, Inc.
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

@available(iOS, deprecated: 26.0)
internal struct ShareActivityDetector {
    static func detect(lessThanWindowLevel windowLevel: UIWindow.Level, scenePersistentIdentifier: String? = nil) -> Bool {
        let windows = WindowDetector.retrieveRelatedWindows(from: scenePersistentIdentifier)
        let behindWindows = windows.filter { window -> Bool in
            window.windowLevel.rawValue < windowLevel.rawValue
        }

        for behindWindow in behindWindows {
            guard var rootViewController = behindWindow.rootViewController else {
                continue
            }

            while let viewController = rootViewController.presentedViewController {
                rootViewController = viewController
            }

            if detect(rootViewController, lessThanWindowLevel: windowLevel) {
                return true
            }
        }
        return false
    }

    static func detect(_ viewController: UIViewController, lessThanWindowLevel windowLevel: UIWindow.Level) -> Bool {
        guard let window = viewController.view.window else {
            // Normally, at the timing of viewDidAppear, ViewController will have "Window" attached to it.
            // However, only when input=file tag is selected in WKWebView of iOS9-11, the ViewController with no Window attached will be passed to the argument of this method.
            // Therefore, the windowLevel judgment will not be done correctly, and the RemoteView judgment will be determined to include RemoteView and the campaign will be reset.
            // In this case, we do not want the campaign reset to take place, so we treat the method as not including RemoteView.
            return false
        }

        guard window.windowLevel.rawValue < windowLevel.rawValue else {
            return false
        }

        return detect(viewController)
    }
}

extension ShareActivityDetector {
    private static func detect(_ viewController: UIViewController) -> Bool {
        if  viewController is UIActivityViewController  ||
                viewController is UICloudSharingController  ||
                viewController.presentedViewController is UIActivityViewController ||
                viewController.presentedViewController is UICloudSharingController {

            return true
        }
        return false
    }
}
