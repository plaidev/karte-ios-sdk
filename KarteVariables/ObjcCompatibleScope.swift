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
import KarteCore

/// SwiftとObjective-Cの互換性のためのクラスです。
///
/// **SDK内部で利用するクラスであり、通常のSDK利用でこちらのクラスを利用することはありません。**
public class ObjcCompatibleScope: NSObject {
    @objc
    public static func trackOpen(variables: [Variable]) {
        trackOpen(variables: variables, values: [:])
    }

    @objc
    public static func trackOpen(variables: [Variable], values: [String: Any]) {
        Tracker.trackOpen(
            variables: variables,
            values: JSONConvertibleConverter.convert(values)
        )
    }

    @objc
    public static func trackClick(variables: [Variable]) {
        trackClick(variables: variables, values: [:])
    }

    @objc
    public static func trackClick(variables: [Variable], values: [String: Any]) {
        Tracker.trackClick(
            variables: variables,
            values: JSONConvertibleConverter.convert(values)
        )
    }

    deinit {}
}
