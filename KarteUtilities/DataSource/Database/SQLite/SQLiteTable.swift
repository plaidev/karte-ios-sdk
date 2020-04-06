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

/// SQLiteのテーブルを表現するためのタイプ
public protocol SQLiteTable {
    /// テーブルのスキーマ情報
    var schema: SQLiteTableSchema { get }

    /// テーブルに対して副作用のないステートメントを実行します。
    /// - Parameters:
    ///   - statement: 実行するステートメント
    ///   - parameters: ステートメントにバインドするパラメータの配列
    /// - Returns: ステートメントの実行結果を返します。
    func query(_ statement: String, parameters: [SQLiteValue]) throws -> [[String: SQLiteValue?]]

    /// テーブルに対して副作用のあるステートメントを実行します。
    /// - Parameters:
    ///   - statement: 実行するステートメント
    ///   - parameters: ステートメントにバインドするパラメータの配列
    func queryUpdate(_ statement: String, parameters: [SQLiteValue]) throws
}

public extension SQLiteTable {
    // swiftlint:disable:next missing_docs
    func query(_ statement: String, parameters: [SQLiteValue]) throws -> [[String: SQLiteValue?]] {
        var rows: [[String: SQLiteValue?]] = []
        try schema.database.open { conn in
            let statement = try conn.statement(for: statement)
            if parameters.isEmpty {
                _ = try statement.execute()
            } else {
                _ = try statement.execute(withParameters: parameters)
            }

            rows = statement.map { row -> [String: SQLiteValue?] in
                row.dictionary
            }
            try statement.finalize()
        }
        return rows
    }

    // swiftlint:disable:next missing_docs
    func queryUpdate(_ statement: String, parameters: [SQLiteValue]) throws {
        try schema.database.open { conn in
            let statement = try conn.statement(for: statement)
            if parameters.isEmpty {
                try statement.executeUpdate()
            } else {
                try statement.executeUpdate(withParameters: parameters)
            }
            try statement.finalize()
        }
    }
}
