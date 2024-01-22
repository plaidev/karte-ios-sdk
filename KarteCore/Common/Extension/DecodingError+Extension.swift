//
//  Copyright 2024 PLAID, Inc.
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

extension DecodingError {

    var debugDescription: String {
        return context?.debugDescription ?? ""
    }

    var key: String {
        return context?.codingPath.first?.stringValue ?? ""
    }

    var context: DecodingError.Context? {
        switch self {
        case .dataCorrupted(let context):
            return context
        case .keyNotFound(_, let context):
            return context
        case .typeMismatch(_, let context):
            return context
        case .valueNotFound(_, let context):
            return context
        default:
            return nil
        }
    }

    var messageWithKey: String {
        if key.isEmpty {
            return localizedDescription
        } else {
            return "key: \(key). \(localizedDescription)"
        }
    }
}
