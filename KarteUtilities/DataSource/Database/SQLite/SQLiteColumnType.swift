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

/// この構造体はSQLiteにおけるカラム型を表します。
public struct SQLiteColumnType {
    /// カラム型名
    public var name: String
}

public extension SQLiteColumnType {
    /// TEXT型
    static let text = SQLiteColumnType(name: "TEXT")

    /// NUMERIC型
    static let numeric = SQLiteColumnType(name: "NUMERIC")

    /// INTEGER型
    static let integer = SQLiteColumnType(name: "INTEGER")

    /// REAL型
    static let real = SQLiteColumnType(name: "REAL")

    /// NONE型
    static let none = SQLiteColumnType(name: "NONE")
}
