//
//  Copyright 2026 PLAID, Inc.
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

final class ConcurrentDictionary<Key: Hashable, Value> {
    private let lock = NSLock()
    private var values: [Key: Value] = [:]

    init(_ values: [Key: Value] = [:]) {
        self.values = values
    }

    /// `key` に対応する値を返す。存在しない場合は `defaultValue` を返す。
    func value(forKey key: Key, default defaultValue: Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return values[key] ?? defaultValue
    }

    /// 全エントリを `newValues` の内容でアトミックに置き換える。
    func updateAll(_ newValues: [Key: Value]) {
        lock.lock()
        defer { lock.unlock() }
        values = newValues
    }
}
