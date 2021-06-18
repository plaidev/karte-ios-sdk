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

import KarteCore

/// RemoteNotificationモジュールの設定を保持するクラスです。
@objc(KRTRemoteNotificationConfiguration)
public class RemoteNotificationConfiguration: NSObject, LibraryConfiguration {
    /// 通知のクリック計測を自動で行うかどうかを表すフラグを返します。<br>
    /// フラグを `false` にした場合は、自動でのクリック計測が行われません。<br>
    /// デフォルトは `true` です。
    @objc public var isEnabledAutoMeasurement = true

    deinit {}
}
