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

/// SceneやSceneSessionの永続化識別子の検出処理を実装した構造体です。
///
/// **SDK内部で利用するタイプであり、通常のSDK利用でこちらのタイプを利用することはありません。**
public struct WindowSceneDetector {
    /// 接続済みのSceneに関連する永続化識別子の配列を返します。
    ///
    /// iOS13未満では常に `nil` が返ります。
    ///
    /// - Returns: 永続化識別子の配列
    public static func retrievePersistentIdentifiers() -> [String]? {
        // swiftlint:disable:previous discouraged_optional_collection
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.map { scene -> String in
                scene.session.persistentIdentifier
            }
        } else {
            return nil
        }
    }

    /// Viewに関連するSceneの永続化識別子を返します。<br>
    /// 引数が `nil` の場合は、接続済みScene配列の先頭のSceneの永続化識別子を返します。
    ///
    /// またiOS13未満では常に `nil` が返ります。
    ///
    /// - Parameter view: `UIView`
    /// - Returns: 永続化識別子
    public static func retrievePersistentIdentifier(view: UIView?) -> String? {
        if #available(iOS 13.0, *) {
            if let identifier = view?.window?.windowScene?.session.persistentIdentifier {
                return identifier
            } else if let window = view as? UIWindow, let identifier = window.windowScene?.session.persistentIdentifier {
                return identifier
            } else {
                return UIApplication.shared.connectedScenes.first?.session.persistentIdentifier
            }
        } else {
            return nil
        }
    }

    /// 永続化識別子に関連する `UIWindowScene` を返します。
    /// - Parameter persistentIdentifier: 永続化識別子
    /// - Returns: `UIWindowScene`
    @available(iOS 13.0, *)
    public static func retrieveWindowScene(from persistentIdentifier: String? = nil) -> UIWindowScene? {
        func matcher(_ scene: UIScene) -> Bool {
            scene.session.persistentIdentifier == persistentIdentifier
        }
        if let scene = UIApplication.shared.connectedScenes.first(where: matcher) as? UIWindowScene {
            return scene
        }
        return nil
    }
}
