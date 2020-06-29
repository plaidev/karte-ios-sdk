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

import Foundation
import UIKit

public protocol BackgroundTaskDelegate: AnyObject {
    func backgroundTaskShouldStart(_ backgroundTask: BackgroundTask) -> Bool
    func backgroundTaskWillStart(_ backgroundTask: BackgroundTask)
    func backgroundTaskDidFinish(_ backgroundTask: BackgroundTask)
}

/// バックグラウンドタスクの状態を管理するためのクラスです。
public class BackgroundTask {
    private var backgroundTaskID = UIBackgroundTaskIdentifier.invalid

    /// `BackgroundTaskDelegate` インスタンスを保持します。
    public weak var delegate: BackgroundTaskDelegate?

    /// イニシャライザ
    public init() {
    }

    /// バックグラウンドタスクを開始します。
    public func start() {
        guard backgroundTaskID == .invalid else {
            return
        }

        delegate?.backgroundTaskWillStart(self)

        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            self.finish()
        }
    }

    /// バックグラウンドタスクを終了します。
    public func finish() {
        guard backgroundTaskID != .invalid else {
            return
        }

        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid

        delegate?.backgroundTaskDidFinish(self)
    }

    /// アプリケーションのライフサイクルイベントの発生を監視します。
    public func observeLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willResignActiveNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    /// アプリケーションのライフサイクルイベントの監視を終了します。
    public func unobserveLifecycle() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc
    private func didBecomeActiveNotification(_ notification: Notification) {
        finish()
    }

    @objc
    private func willResignActiveNotification(_ notification: Notification) {
        guard delegate?.backgroundTaskShouldStart(self) ?? true else {
            return
        }
        start()
    }

    deinit {
    }
}
