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

/// SDKの実験的な設定を保持するクラスです。
@objc(KRTExperimentalConfiguration)
@objcMembers
public class ExperimentalConfiguration: Configuration {
    /// デフォルト値で初期化された設定インスタンスを返します。
    override public class var defaultConfiguration: ExperimentalConfiguration {
        ExperimentalConfiguration()
    }

    /// 動作モードの取得・設定を行います。<br>
    ///
    /// **実験的なオプションであるため、通常のSDK利用においてこちらのプロパティを変更する必要はありません。**
    public var operationMode = OperationMode.default

    /// SDK設定インスタンスを初期化します。
    override public init() {
        super.init()
    }

    /// SDK設定インスタンスを初期化します。
    ///
    /// - Parameter configurator: 初期化ブロック
    public convenience init(configurator: (ExperimentalConfiguration) -> Void) {
        self.init()
        configurator(self)
    }

    /// SDK設定インスタンスを初期化します。
    ///
    /// - Parameter configurator: 初期化ブロック
    override public class func config(configurator: (ExperimentalConfiguration) -> Void) -> ExperimentalConfiguration {
        ExperimentalConfiguration(configurator: configurator)
    }

    /// インスタンスをコピーします。
    ///
    /// - Parameter zone: NSZone
    override public func copy(with zone: NSZone? = nil) -> Any {
        let configuration = ExperimentalConfiguration()
        configuration.baseURL = baseURL
        configuration.overlayBaseURL = overlayBaseURL
        configuration.isDryRun = isDryRun
        configuration.isOptOut = isOptOut
        configuration.isSendInitializationEventEnabled = isSendInitializationEventEnabled
        configuration.idfaDelegate = idfaDelegate

        // experimental configuraiton
        configuration.operationMode = operationMode
        return configuration
    }

    deinit {
    }
}
