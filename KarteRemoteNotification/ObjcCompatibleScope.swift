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

import Foundation

/// SwiftとObjective-Cの互換性のためのクラスです。
///
/// **SDK内部で利用するクラスであり、通常のSDK利用でこちらのクラスを利用することはありません。**
public class ObjcCompatibleScope: NSObject {
    @objc
    public static func registerFCMToken(_ fcmToken: String?) {
        FCMTokenRegistrar.shared.registerFCMToken(fcmToken)
    }

    @objc
    public static func trackClick(userInfo: [AnyHashable: Any]) {
        Measurement.measure(userInfo: userInfo)
    }

    deinit {}
}
