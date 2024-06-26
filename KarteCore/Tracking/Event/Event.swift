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

/// イベントを表現するタイプです。
public struct Event: Codable {
    /// イベント名
    ///
    /// イベント名には半角小文字英字 ( a-z )、半角数字 ( 0-9 ) と下線 ( _ ) のみ使用できます。<br>
    /// なお下線 ( _ ) で始まるイベント名はシステム上のイベントと干渉するため使用できません。
    public var eventName: EventName

    /// イベントに紐付けるカスタムオブジェクト
    ///
    /// ### フィールド名の制限
    /// * ドット ( `.` ) を含む名称は使用できません。
    /// * `$` で始まる名前は使用できません。
    /// * フィールド名として `_source` `any` `avg` `cache` `count` `count_sets` `date` `f_t` `first` `keys` `l_t` `last` `lrus` `max` `min` `o` `prev` `sets` `size` `span` `sum` `type` `v` を指定することはできません。
    ///
    /// ### 値の制限
    /// 送信可能なデータ型は、下記の通りです。
    /// * `String`
    /// * `Int` `Int8` `Int16` `Int32` `Int64`
    /// * `UInt` `UInt8` `UInt16 ` `UInt32` `UInt64`
    /// * `Double` `Float`
    /// * `Bool`
    /// * `Date`
    /// * `Array`
    /// * `Dictionary`
    public var values: [String: JSONValue]

    /// イベント発生源のライブラリ名
    public var libraryName: String?

    var isRetryable: Bool {
        eventName.isRetryable
    }

    public init(eventName: EventName, values: [String: JSONConvertible] = [:], libraryName: String? = nil) {
        self.eventName = eventName
        self.values = values.mapValues { $0.jsonValue }
        self.libraryName = libraryName
    }

    public init(_ alias: Alias, libraryName: String? = nil) {
        (eventName, values) = alias.build()
        self.libraryName = libraryName
    }

    public mutating func merge(_ other: [String: JSONConvertible]) {
        values.mergeRecursive(other.mapValues { $0.jsonValue })
    }

    mutating func mergeAdditionalParameter(date: Date, isRetry: Bool) {
        var other: [String: JSONConvertible] = [
            field(.localEventDate): date
        ]
        if isRetry {
            other[field(.retry)] = isRetry
        }

        merge(other)
    }
}

public extension Event {
    /// 各イベントのエイリアスを定義した列挙型です。
    enum Alias {
        /// `view` イベント
        case view(viewName: String, title: String, values: [String: JSONConvertible])
        /// `identify` イベント
        case identify(userId: String, values: [String: JSONConvertible])
        /// `attribute` イベント
        case attribute(values: [String: JSONConvertible])
        /// `native_app_open` イベント
        case open
        /// `native_app_foreground` イベント
        case foreground
        /// `native_app_background` イベント
        case background
        /// `native_app_install` イベント
        case install
        /// `native_app_update` イベント
        case update(version: String?)
        /// `deep_link_app_open` イベント
        case deepLinkAppOpen(url: String)
        /// `message_xxxxx` イベント
        case message(type: MessageType, campaignId: String, shortenId: String, values: [String: JSONConvertible])
        /// `native_app_renew_visitor_id` イベント
        case renewVisitorId(old: String?, new: String?)
        /// `plugin_native_app_identify` イベント
        case pluginNativeAppIdentify(subscribe: Bool, fcmToken: String?)
        /// `_fetch_variables` イベント
        case fetchVariables
        /// `att_status_updated`イベント
        case attStatusUpdated(attStatus: String)

        /// 列挙子に応じた `イベント名` および `オブジェクト` を返します。
        func build() -> (EventName, [String: JSONValue]) {
            // swiftlint:disable:previous cyclomatic_complexity function_body_length
            let name: EventName
            let vals: [String: JSONConvertible]
            switch self {
            case let .view(viewName: viewName, title: title, values: values):
                let other: [String: JSONConvertible] = [
                    field(.viewName): viewName,
                    field(.title): title
                ]
                name = .view
                vals = values.mergingRecursive(other)

            case let .identify(userId: userId, values: values):
                let other: [String: JSONConvertible] = [
                    field(.userId): userId
                ]
                name = .identify
                vals = values.mergingRecursive(other)

            case let .attribute(values: values):
                name = .attribute
                vals = values

            case .open:
                name = .nativeAppOpen
                vals = [:]

            case .foreground:
                name = .nativeAppForeground
                vals = [:]

            case .background:
                name = .nativeAppBackground
                vals = [:]

            case .install:
                name = .nativeAppInstall
                vals = [:]

            case let .update(version: version):
                name = .nativeAppUpdate
                vals = [field(.previousVersionName): version].compactMapValues { $0 }

            case let .deepLinkAppOpen(url: url):
                name = .deepLinkAppOpen
                vals = [field(.url): url].compactMapValues { $0 }

            case let .message(type: type, campaignId: campaignId, shortenId: shortenId, values: values):
                let other: [String: JSONConvertible] = [
                    field(.message): [
                        field(.campaignId): campaignId,
                        field(.shortenId): shortenId
                    ]
                ]
                name = type.eventName
                vals = values.mergingRecursive(other)

            case let .renewVisitorId(old: old, new: new):
                var values = [String: JSONConvertible]()
                if let old = old {
                    values[field(.oldVisitorId)] = old
                }
                if let new = new {
                    values[field(.newVisitorId)] = new
                }
                name = .nativeAppRenewVisitorId
                vals = values

            case let .pluginNativeAppIdentify(subscribe: subscribe, fcmToken: fcmToken):
                let values: [String: JSONConvertible?] = [
                    field(.subscribe): subscribe,
                    field(.fcmToken): fcmToken
                ]
                name = .pluginNativeAppIdentify
                vals = values.compactMapValues { $0 }

            case let .attStatusUpdated(attStatus: attStatus):
                let values: [String: JSONConvertible?] = [
                    field(.attStatus): attStatus
                ]

                name = .attStatusUpdated
                vals = values.compactMapValues { $0 }

            case .fetchVariables:
                name = .fetchVariables
                vals = [:]
            }

            return (name, vals.mapValues { $0.jsonValue })
        }
    }

    /// message_xxx イベントのタイプを定義した列挙型です。
    enum MessageType {
        /// `_message_ready` イベント
        case ready
        /// `message_open` イベント
        case open
        /// `message_close` イベント
        case close
        /// `message_click` イベント
        case click
        /// `_message_suppressed` イベント
        case suppressed

        var eventName: EventName {
            switch self {
            case .ready:
                return .messageReady

            case .open:
                return .messageOpen

            case .close:
                return .messageClose

            case .click:
                return .messageClick

            case .suppressed:
                return .messageSuppressed
            }
        }

        init(_ eventName: EventName) throws {
            switch eventName {
            case .messageReady:
                self = .ready

            case .messageOpen:
                self = .open

            case .messageClose:
                self = .close

            case .messageClick:
                self = .click

            case .messageSuppressed:
                self = .suppressed

            default:
                throw NSError(domain: "io.karte.core", code: 0, userInfo: nil)
            }
        }
    }
}

private extension Event {
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case values
        case libraryName
    }
}
