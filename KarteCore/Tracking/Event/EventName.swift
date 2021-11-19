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

/// イベント名を表現する構造体です。
public struct EventName: Codable {
    /// イベント名
    public let rawValue: String

    var isInitializationEvent: Bool {
        switch self {
        case .nativeAppInstall, .nativeAppUpdate, .nativeAppOpen, .nativeAppCrashed:
            return true

        default:
            return false
        }
    }

    var isRetryable: Bool {
        switch self {
        case .fetchVariables:
            return false

        default:
            return true
        }
    }

    var isUserDefinedEvent: Bool {
        switch self {
        case .view, .identify, .attribute,
            .nativeAppInstall, .nativeAppUpdate, .nativeAppOpen, .nativeAppCrashed,
            .nativeAppForeground, .nativeAppBackground, .nativeAppRenewVisitorId,
            .nativeFindMyself, .deepLinkAppOpen,
            .messageReady, .messageOpen, .messageClick, .messageClose, .messageSuppressed,
            .massPushClick,
            .pluginNativeAppIdentify,
            .fetchVariables:
            return false
        default:
            return true
        }
    }

    /// 構造体を初期化します。
    ///
    /// - Parameter rawValue: イベント名
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension EventName: Equatable {
    public static func == (lhs: EventName, rhs: EventName) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

public extension EventName {
    /// view イベント
    static let view                      = EventName("view")
    /// identify イベント
    static let identify                  = EventName("identify")
    /// attribute イベント
    static let attribute                  = EventName("attribute")
    /// native_app_install イベント
    static let nativeAppInstall          = EventName("native_app_install")
    /// native_app_update イベント
    static let nativeAppUpdate           = EventName("native_app_update")
    /// native_app_open イベント
    static let nativeAppOpen             = EventName("native_app_open")
    /// native_app_foreground イベント
    static let nativeAppForeground       = EventName("native_app_foreground")
    /// native_app_background イベント
    static let nativeAppBackground       = EventName("native_app_background")
    /// native_app_crashed イベント
    static let nativeAppCrashed          = EventName("native_app_crashed")
    /// native_app_renew_visitor_id イベント
    static let nativeAppRenewVisitorId   = EventName("native_app_renew_visitor_id")
    /// native_find_myself イベント
    static let nativeFindMyself          = EventName("native_find_myself")
    /// deep_link_app_open イベント
    static let deepLinkAppOpen           = EventName("deep_link_app_open")
    /// _message_ready イベント
    static let messageReady              = EventName("_message_ready")
    /// message_open イベント
    static let messageOpen               = EventName("message_open")
    /// message_close イベント
    static let messageClose              = EventName("message_close")
    /// message_click イベント
    static let messageClick              = EventName("message_click")
    /// _message_suppressed イベント
    static let messageSuppressed         = EventName("_message_suppressed")
    /// mass_push_click イベント
    static let massPushClick             = EventName("mass_push_click")
    /// plugin_native_app_identify イベント
    static let pluginNativeAppIdentify   = EventName("plugin_native_app_identify")
    /// _fetch_variables イベント
    static let fetchVariables            = EventName("_fetch_variables")
}
