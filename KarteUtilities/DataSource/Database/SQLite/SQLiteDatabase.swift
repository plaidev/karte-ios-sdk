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

/// SQLiteデータベースインスタンスを表すクラス。
public class SQLiteDatabase {
    private let queue: DatabaseQueue

    /// SQLiteデータベースインスタンスを作成します。
    /// SQLiteファイルはアプリケーションサンドボックス内の Library ディレクトリ内に作成されます。
    /// 既に同名のSQLiteファイルが存在する場合は、それを利用してインスタンスを作成します。
    /// - Parameter name: SQLiteファイル名
    public init(name: String) {
        // swiftlint:disable:next force_try
        let url = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        self.queue = DatabaseQueue(location: url.appendingPathComponent(name))
    }

    /// SQLiteデータベースに対するコネクションをオープンします。
    /// - Parameter block: オープンされたコネクションを受け取るためのブロック
    public func open(_ block: ((DatabaseConnection) throws -> Void)) throws {
        try queue.database(block)
    }

    deinit {
    }
}
