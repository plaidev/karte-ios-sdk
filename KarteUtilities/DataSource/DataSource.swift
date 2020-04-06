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

/// データソースに対する操作を表現するタイプです。
public protocol DataSource {
    /// データソースにデータが存在するか返します。
    var isExist: Bool { get }

    /// データソースからデータを読み込みます。
    ///
    /// - Returns: 読み込んだデータを返します。
    func read() throws -> Data

    /// データソースにデータを書き込みます。
    ///
    /// - Parameter data: 書き込むデータを指定します。
    func write(_ data: Data) throws

    /// データソースからデータを削除します。
    func delete() throws
}
