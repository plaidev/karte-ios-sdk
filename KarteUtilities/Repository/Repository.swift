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

/// リポジトリに対するデータの読み書き等の操作を表現するタイプです。
public protocol Repository {
    /// リポジトリにデータが存在するかどうかを返します。
    var isExist: Bool { get }

    /// リポジトリに存在するデータを読み込みます。
    /// - Parameter type: 読み込むデータの型を指定します。
    /// - Returns: 指定したデータ型に対応するインスタンスを返します。
    func read<T>(_ type: T.Type) throws -> T where T: Decodable

    /// リポジトリにデータを書き込みます。
    /// - Parameter instance: 書き込むデータのインスタンスを指定します。
    func write<T>(_ instance: T) throws where T: Encodable

    /// リポジトリからデータを削除します。
    func delete() throws
}
