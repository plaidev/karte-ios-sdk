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
import ObjectiveC

public extension NSObject {
    /// メソッドのセレクタに対応する実装を交換します。
    /// - Parameters:
    ///   - from: 交換元のセレクタ
    ///   - to: 交換先のセレクタ
    static func exchangeInstanceMethod(from: Selector, to: Selector) {
        // swiftlint:disable:previous identifier_name
        let fromMethod = class_getInstanceMethod(self, from)
        let toMethod = class_getInstanceMethod(self, to)

        if let fromMethod = fromMethod, let toMethod = toMethod {
            method_exchangeImplementations(fromMethod, toMethod)
        }
    }
}
