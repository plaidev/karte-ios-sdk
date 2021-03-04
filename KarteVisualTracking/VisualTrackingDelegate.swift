//
//  Copyright 2021 PLAID, Inc.
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

/// ビジュアルトラッキングで発生するイベントを委譲するためのタイプです。
@objc(KRTVisualTrackingDelegate)
public protocol VisualTrackingDelegate: AnyObject {
    /// ペアリング状態が更新されたことを通知します。
    ///
    /// - Parameters:
    ///   - visualTracking: ビジュアルトラッキングインスタンス
    ///   - isPaired: ペアリング状態を表すフラグ、端末がペアリングされていればtrue 、それ以外は false を返します。
    @objc
    optional func visualTrackingDevicePairingStatusUpdated(_ visualTracking: VisualTracking, isPaired: Bool)
}
