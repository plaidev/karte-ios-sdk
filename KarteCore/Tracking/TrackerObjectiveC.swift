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

/// イベントトラッキングを行うためのクラスです。
///
/// 送信するイベントの種類に応じて、複数のメソッドが用意されております。
///
/// ### track
/// 任意の名前のイベントを送る場合に利用します。
///
/// ### identify
/// ユーザーに関する情報（ユーザーIDや名前、メールアドレス等）を送る場合に利用します。
///
/// ### view
/// 画面表示に関する情報を送る場合に利用します。<br>
/// 通常は `viewDidAppear:` 等で呼び出します。
///
/// なおViewイベントに関しては、イベントの送信だけではなくアプリ上で画面遷移が発生したことを認識するためのものとしても利用されます。<br>
/// 具体的には、Viewイベントを発火させたタイミングで、既にアプリ内メッセージが表示されている場合は、自動でアプリ内メッセージを非表示にします。<br>
/// また [ネイティブアプリにおける接客表示制限](https://support.karte.io/post/3JaA3BlXQea59AaPGxD3bb) オプションを有効にした場合にも、ここで設定した認識結果が利用されます。
///
/// ### iPad OS における Split View / Slide Over 対応について
/// iPad OS の Split View / Slide Over に対応するために、イニシャライザに `UIView` を引数として取るものがあります。<br>
/// Split View / Slide Over を有効がアプリケーションでは、`UIView` を引数として取るイニシャライザを利用することで適切なシーンにアプリ内メッセージを表示することが可能です。
@objc(KRTTracker)
public class TrackerObjectiveC: NSObject {
    private var view: UIView?

    /// トラッカーインスタンスを初期化します。
    ///
    /// - Parameter view: イベントの発火に関連する `UIView`。イベント発火に関連するシーンの特定に利用されます。
    @objc
    public init(view: UIView?) {
        self.view = view
    }

    /// イベントの送信を行います。
    ///
    /// - Parameter name: イベント名
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func track(_ name: String) -> TrackingTask {
        let task = track(name, values: [:])
        return task
    }

    /// イベントの送信を行います。
    ///
    /// - Parameters:
    ///   - name: イベント名
    ///   - values: イベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func track(_ name: String, values: [String: Any]) -> TrackingTask {
        let task = Tracker.track(
            name, values: JSONConvertibleConverter.convert(values)
        )
        return task
    }

    /// Identifyイベントの送信を行います。
    ///
    /// - Parameter values: Identifyイベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func identify(_ values: [String: Any]) -> TrackingTask {
        let task = Tracker.identify(JSONConvertibleConverter.convert(values))
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameter viewName: 画面名
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func view(_ viewName: String) -> TrackingTask {
        let task = view(viewName, title: nil)
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameters:
    ///   - viewName: 画面名
    ///   - title: タイトル
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func view(_ viewName: String, title: String?) -> TrackingTask {
        let task = view(viewName, title: title, values: [:])
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameters:
    ///   - viewName: 画面名
    ///   - title: タイトル
    ///   - values: Viewイベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public static func view(_ viewName: String, title: String?, values: [String: Any]) -> TrackingTask {
        let task = Tracker.view(
            viewName,
            title: title,
            values: JSONConvertibleConverter.convert(values)
        )
        return task
    }

    /// イベントの送信を行います。
    ///
    /// - Parameter name: イベント名
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func track(_ name: String) -> TrackingTask {
        let task = track(name, values: [:])
        return task
    }

    /// イベントの送信を行います。
    ///
    /// - Parameters:
    ///   - name: イベント名
    ///   - values: イベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func track(_ name: String, values: [String: Any]) -> TrackingTask {
        let task = Tracker(view: view).track(
            name,
            values: JSONConvertibleConverter.convert(values)
        )
        return task
    }

    /// Identifyイベントの送信を行います。
    ///
    /// - Parameter values: Identifyイベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func identify(_ values: [String: Any]) -> TrackingTask {
        let task = Tracker(view: view).identify(JSONConvertibleConverter.convert(values))
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameter viewName: 画面名
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func view(_ viewName: String) -> TrackingTask {
        let task = view(viewName, title: nil)
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameters:
    ///   - viewName: 画面名
    ///   - title: タイトル
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func view(_ viewName: String, title: String?) -> TrackingTask {
        let task = view(viewName, title: title, values: [:])
        return task
    }

    /// Viewイベントの送信を行います。
    ///
    /// - Parameters:
    ///   - viewName: 画面名
    ///   - title: タイトル
    ///   - values: Viewイベントに紐付けるカスタムオブジェクト
    /// - Returns: トラッキングタスクの状態を保持するオブジェクトを返します。
    @objc
    @discardableResult
    public func view(_ viewName: String, title: String?, values: [String: Any]) -> TrackingTask {
        let task = Tracker(view: view).view(
            viewName,
            title: title,
            values: JSONConvertibleConverter.convert(values)
        )
        return task
    }

    deinit {
    }
}
