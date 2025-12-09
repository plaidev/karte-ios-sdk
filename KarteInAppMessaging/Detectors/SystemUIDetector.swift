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
import SwiftUI

internal struct SystemUIDetector {
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
            return false
        }

        guard window.windowLevel.rawValue < windowLevel.rawValue else {
            return false
        }

        return detect(viewController)
    }
}

extension SystemUIDetector {
    private static func detect(_ viewController: UIViewController) -> Bool {
        if let config = InAppMessaging.shared.config, config.isSkipSystemUIDetectionInWebView || config.isSkipRemoteViewDetectionInWebView {
            return false
        }
        guard viewController.isBeingDismissed == false else {
            return false
        }
        return isListedDetectionType(viewController)
    }
    private static func isListedDetectionType(_ viewController: UIViewController) -> Bool {
        var detectionTargets = [
            UIAlertController.self,
            UIActivityViewController.self,
            UICloudSharingController.self,
            UIColorPickerViewController.self,
            UIDocumentBrowserViewController.self,
            UIDocumentInteractionController.self,
            UIDocumentPickerViewController.self,
            UIFontPickerViewController.self,
            UIImagePickerController.self,
            UIPrinterPickerController.self,
            UIPrintInteractionController.self,
            UIReferenceLibraryViewController.self,
            UIVideoEditorController.self,
            ClassLoader.printPanelViewControllerClass.self,
            NSClassFromString("VNDocumentCameraViewController").self,
            NSClassFromString("SKStoreProductViewController").self,
            NSClassFromString("SKCloudServiceSetupViewController").self,
            NSClassFromString("RPPreviewViewController").self,
            NSClassFromString("RPBroadcastActivityViewController").self,
            NSClassFromString("QLPreviewController").self,
            NSClassFromString("PHPickerViewController").self,
            NSClassFromString("MPMediaPickerController").self,
            NSClassFromString("MKMapItemDetailViewController").self,
            NSClassFromString("MKLookAroundViewController").self,
            NSClassFromString("MFMessageComposeViewController").self,
            NSClassFromString("MFMailComposeViewController").self,
            NSClassFromString("MCBrowserViewController").self,
            NSClassFromString("SFSafariViewController").self,
            NSClassFromString("INUIEditVoiceShortcutViewController").self,
            NSClassFromString("INUIAddVoiceShortcutViewController").self,
            NSClassFromString("CABTMIDICentralViewController").self,
            NSClassFromString("CABTMIDILocalPeripheralViewController").self,
            NSClassFromString("CNContactPickerViewController").self,
            NSClassFromString("CNContactViewController").self,
            NSClassFromString("EKEventEditViewController").self,
            NSClassFromString("EKEventViewController").self,
            NSClassFromString("AVPlayerViewController").self,
            NSClassFromString("VisionKit.DataScannerViewController").self,
            NSClassFromString("HKHealthPrivacyHostAuthorizationViewController").self
        ]
        if #available(iOS 17.0, *) {
            detectionTargets.append(UIDocumentViewController.self)
        }
        if #available(iOS 18.0, *) {
            detectionTargets.append(UITextFormattingViewController.self)
        }
        return detectionTargets.compactMap({ $0 }).contains(where: { type in
            viewController.isKind(of: type)
        })
    }
}
