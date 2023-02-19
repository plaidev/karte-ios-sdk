//
//  Copyright 2022 PLAID, Inc.
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

/// Karteから送信したPush通知の履歴を取得するクラスです。
@objc(KRTInbox)
public class Inbox: NSObject {
    static let shared = Inbox()

    private var _apiKey: String?

    public static var currentApiKey: String {
        shared._apiKey ?? ""
    }

    override private init() {}

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    /// Push通知の送信履歴を取得します。エラー発生時はnilを返します。
    /// - Parameter userId: 取得対象のユーザーのユーザーID。未Identify状態のユーザー（visitor）の履歴は取得できません。
    /// - Parameter limit: 最大取得件数を指定します。デフォルトは最新50件を取得します。
    /// - Parameter latestMessageId: この値で指定されたmessageIdより前の履歴を取得します。指定したmessageIdを持つ履歴は戻り値に含まれません。
    public static func fetchMessages(by userId: String, limit: UInt? = nil, latestMessageId: String? = nil) async -> [InboxMessage]? {
        return await InboxClient.fetchMessages(by: userId, limit: limit, latestMessageId: latestMessageId)
    }
}

extension Inbox: Library {
    public static var name: String {
        "inbox"
    }

    public static var version: String {
        KRTInboxCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        shared._apiKey = app.configuration.apiKey
    }

    public static func unconfigure(app: KarteApp) {}
}
