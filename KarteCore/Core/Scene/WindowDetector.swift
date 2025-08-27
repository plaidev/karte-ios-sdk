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
    /// ウィンドウが見つからない場合は、空の配列を返します。
    /// - Parameter view: `UIView`
    /// - Returns: `UIWindow` の配列
    public static func retrieveRelatedWindows(view: UIView) -> [UIWindow] {
        if let windows = view.window?.windowScene?.windows {
            return windows
        }
        if let window = view as? UIWindow {
            return [window]
        }
        return []
    }

    /// Sceneが管理しているWindowの配列を返します。
    /// ウィンドウが見つからない場合は、空の配列を返します。
    /// - Parameter persistentIdentifier: `UISceneSession` が持つ永続化識別子
    /// - Parameter application: 通常は`UIApplication.shared`が入ります
    /// - Returns: `UIWindow` の配列
    public static func retrieveRelatedWindows(
        from persistentIdentifier: String? = nil,
        application: UIApplicationProtocol? = UIApplication.shared
    ) -> [UIWindow] {
        guard let application else {
            return []
        }
        if let scene = WindowSceneDetector.retrieveWindowScene(from: persistentIdentifier, application: application) {
            return scene.windows
        } else if let scene = application.connectedScenes.first as? UIWindowScene {
            return scene.windows
        }
        return []
    }
}
