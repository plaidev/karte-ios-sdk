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
import KarteCore

public extension TrackerObjectiveC {
    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_open）を発火します。
    ///
    /// - Parameter variables: 設定値の配列
    @objc
    class func trackOpen(variables: [Variable]) {
        trackOpen(variables: variables, values: [:])
    }

    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_open）を発火します。
    ///
    /// - Parameters:
    ///   - variables: 設定値の配列
    ///   - values: イベントに紐付けるカスタムオブジェクト
    @objc
    class func trackOpen(variables: [Variable], values: [String: Any]) {
        Tracker.trackOpen(
            variables: variables,
            values: JSONConvertibleConverter.convert(values)
        )
    }

    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_click）を発火します。
    ///
    /// - Parameter variables: 設定値の配列
    @objc
    class func trackClick(variables: [Variable]) {
        trackClick(variables: variables, values: [:])
    }

    /// 指定された設定値に関連するキャンペーン情報を元に効果測定用のイベント（message_click）を発火します。
    ///
    /// - Parameters:
    ///   - variables: 設定値の配列
    ///   - values: イベントに紐付けるカスタムオブジェクト
    @objc
    class func trackClick(variables: [Variable], values: [String: Any]) {
        Tracker.trackClick(
            variables: variables,
            values: JSONConvertibleConverter.convert(values)
        )
    }
}
