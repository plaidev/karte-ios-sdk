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
    /// - Parameter application: 通常はUIApplication.sharedが入ります。
    /// - Returns: 永続化識別子の配列
    public static func retrievePersistentIdentifiers(
        application: UIApplicationProtocol? = UIApplication.shared
    ) -> [String]? {
        guard let application else {
            return nil
        }
        // swiftlint:disable:previous discouraged_optional_collection
        return application.connectedScenes.map { scene -> String in
            scene.session.persistentIdentifier
        }
    }

    /// Viewに関連するSceneの永続化識別子を返します。<br>
    /// 引数が `nil` の場合は、接続済みScene配列の先頭のSceneの永続化識別子を返します。
    ///
    /// - Parameter view: `UIView`
    /// - Parameter application: 通常はUIApplication.sharedが入ります。
    /// - Returns: 永続化識別子
    public static func retrievePersistentIdentifier(
        view: UIView?,
        application: UIApplicationProtocol? = UIApplication.shared
    ) -> String? {
        guard let application else {
            return nil
        }
        if let identifier = view?.window?.windowScene?.session.persistentIdentifier {
            return identifier
        } else if let window = view as? UIWindow, let identifier = window.windowScene?.session.persistentIdentifier {
            return identifier
        }
        return application.connectedScenes.first?.session.persistentIdentifier
    }

    /// 永続化識別子に関連する `UIWindowScene` を返します。
    /// - Parameter persistentIdentifier: 永続化識別子
    /// - Parameter application: 通常はUIApplication.sharedが入ります。
    /// - Returns: `UIWindowScene`
    public static func retrieveWindowScene(
        from persistentIdentifier: String? = nil,
        application: UIApplicationProtocol? = UIApplication.shared
    ) -> UIWindowScene? {
        guard let application else {
            return nil
        }
        func matcher(_ scene: UIScene) -> Bool {
            scene.session.persistentIdentifier == persistentIdentifier
        }
        if let scene = application.connectedScenes.first(where: matcher) as? UIWindowScene {
            return scene
        }
        return nil
    }
}
