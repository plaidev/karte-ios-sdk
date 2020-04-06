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

/// SQLiteのテーブルスキーマを表現するタイプ
public protocol SQLiteTableSchema {
    /// SQLiteデータベースインスタンス
    var database: SQLiteDatabase { get }
    /// テーブル名
    var name: String { get }
    /// テーブルを構成するカラムの配列
    var columns: [SQLiteColumn] { get }

    /// テーブルを作成します。
    func create() throws
    /// テーブルを削除します。
    func drop() throws
    /// テーブルの有無を返します。
    /// - Returns: テーブルが存在する場合は `true` を返します。存在しない場合は `false` を返します。
    func exists() throws -> Bool
}

public extension SQLiteTableSchema {
    // swiftlint:disable:next missing_docs
    func create() throws {
        if try exists() {
            return
        }

        let schema = columns.map { column -> String in
            "\(column.name) \(column.type.name) \(column.constraints)"
        }.joined(separator: ", ")

        let statement = "CREATE TABLE IF NOT EXISTS \(name)(\(schema));"
        try database.open { conn in
            try conn.statement(for: statement).executeUpdate().finalize()
        }

        SQLiteTableCache.addCache(name)
    }

    // swiftlint:disable:next missing_docs
    func drop() throws {
        guard try exists() else {
            return
        }

        let statement = "DROP TABLE \(name)"
        try database.open { conn in
            try conn.statement(for: statement).executeUpdate().finalize()
        }

        SQLiteTableCache.removeCache(name)
    }

    // swiftlint:disable:next missing_docs
    func exists() throws -> Bool {
        if SQLiteTableCache.hasCache(name) {
            return true
        }

        var isExists = false
        try database.open { conn in
            isExists = try conn.contains(table: name)
        }
        return isExists
    }
}
