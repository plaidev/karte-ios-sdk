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

import UIKit

/// Windowの検出処理を実装した構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct WindowDetector {
    /// Sceneが管理しているWindowの配列を返します。
    /// iOS13未満では `UIApplication` が管理するWindowの配列を返します。
    /// - Parameter view: `UIView`
    /// - Returns: `UIWindow` の配列
    public static func retrieveRelatedWindows(view: UIView) -> [UIWindow] {
        if #available(iOS 13.0, *) {
            if let windows = view.window?.windowScene?.windows {
                return windows
            }
            if let window = view as? UIWindow {
                return [window]
            }
        }
        return UIApplication.shared.windows
    }

    /// Sceneが管理しているWindowの配列を返します。
    /// iOS13未満では `UIApplication` が管理するWindowの配列を返します。
    /// - Parameter persistentIdentifier: `UISceneSession` が持つ永続化識別子
    /// - Returns: `UIWindow` の配列
    public static func retrieveRelatedWindows(from persistentIdentifier: String? = nil) -> [UIWindow] {
        if #available(iOS 13.0, *) {
            if let scene = WindowSceneDetector.retrieveWindowScene(from: persistentIdentifier) {
                return scene.windows
            } else if UIApplication.shared.responds(to: #selector(getter: UIApplication.connectedScenes)) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return scene.windows
                }
            }
        }
        return UIApplication.shared.windows
    }
}
