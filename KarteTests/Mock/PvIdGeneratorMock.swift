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
@testable import KarteCore

final class PvIdGeneratorMock: IdGenerator {
    private var ids: [String]
    private(set) var index = 0

    init(ids: [String]) {
        self.ids = ids
    }

    func generate() -> String {
        guard index < ids.count else {
            return "unexpected-pv-id-\(index)"
        }
        defer { index += 1 }
        return ids[index]
    }
}
