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

/// この構造体はSQLiteカラムの情報を保持します。
public struct SQLiteColumn {
    /// カラム名
    public var name: String
    /// カラム型
    public var type: SQLiteColumnType
    /// カラム制約
    public var constraints: String

    /// カラムの定義を作成します。
    /// - Parameters:
    ///   - name: カラム名
    ///   - type: カラム型
    ///   - constraints: カラム制約
    public init(_ name: String, type: SQLiteColumnType, constraints: String) {
        self.name = name
        self.type = type
        self.constraints = constraints
    }
}
