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

import Foundation
import UIKit
import KarteCore
import KarteVariables

@available(iOS 14.0, *)
@objc(KRTInAppFrame)
public final class InAppFrame: NSObject {
    @objc public static let shared = InAppFrame()
    private(set) weak var loadingDelegate: LoadingDelegate?
    private(set) var itemTapListener: ItemTapListener?

    override private init() {}

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    public static func loadContent(for variableKey: String) async -> UIView? {
        guard let arg = VariableParser.parse(for: variableKey) else {
            return nil
        }
        return await InAppFrameFactory.create(
            for: arg, loadingDelegate: Self.shared.loadingDelegate, itemTapListener: Self.shared.itemTapListener
        )
    }

    public static func update() async -> Bool {
        return await withCheckedContinuation { continuation in
            Variables.fetch { result in
                continuation.resume(returning: result)
            }
        }
    }

    public enum LoadingState {
        case initialized
        case loading
        case completed
        case failed
    }

    public typealias ItemTapListener = (URL) -> Bool

    @MainActor
    public protocol LoadingDelegate: AnyObject {
        func didChangeLoadingState(to state: LoadingState)
    }

    @MainActor
    public static func setLoadingDelegate(_ delegate: LoadingDelegate?) {
        Self.shared.loadingDelegate = delegate
    }

    public static func setItemTapListener(_ listener: ItemTapListener?) {
        Self.shared.itemTapListener = listener
    }

    @MainActor
    public static func reset() {
        Self.shared.loadingDelegate = nil
        Self.shared.itemTapListener = nil
    }
}

@available(iOS 14.0, *)
extension InAppFrame: Library {
    public static var name: String {
        "in_app_frame"
    }

    public static var version: String {
        KRTInAppFrameCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {}

    public static func unconfigure(app: KarteApp) {
        Task {
            await InAppFrame.reset()
        }
    }
}

extension Logger.Tag {
    static let inAppFrame = Logger.Tag("InAppFrame", version: KRTInAppFrameCurrentLibraryVersion())
}
