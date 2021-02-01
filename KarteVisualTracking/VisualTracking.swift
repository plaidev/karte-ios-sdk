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

/// VisualTrackingモジュールクラスです。
@objc(KRTVisualTracking)
public class VisualTracking: NSObject {
    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    deinit {
    }
}

extension VisualTracking: Library {
    public static var name: String {
        "visual_tracking"
    }

    public static var version: String {
        KRTVisualTrackingCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        app.register(module: .deeplink(VisualTrackingManager.shared))
        app.register(module: .action(VisualTrackingManager.shared))
        app.register(module: .track(VisualTrackingManager.shared))

        VisualTrackingManager.shared.configure(app: app)
    }

    public static func unconfigure(app: KarteApp) {
        app.unregister(module: .deeplink(VisualTrackingManager.shared))
        app.unregister(module: .action(VisualTrackingManager.shared))
        app.unregister(module: .track(VisualTrackingManager.shared))

        VisualTrackingManager.shared.unconfigure(app: app)
    }

    /// 操作ログをハンドルします。<br>
    ///
    /// 操作ログはペアリング時のみ送信されます<br>
    /// イベント発火条件定義に操作ログがマッチした際にビジュアルイベントが送信されます。
    ///
    /// - Parameter actionProtocol: ActionProtocol
    public static func handle(actionProtocol: ActionProtocol) {
        VisualTrackingManager.shared.dispatch(action: actionProtocol)
    }
}

extension Logger.Tag {
    static let visualTracking = Logger.Tag("VT", version: KRTVisualTrackingCurrentLibraryVersion())
}
