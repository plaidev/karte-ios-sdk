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

public extension URL {
    /// RFC2396に適合するURLに変換します。
    /// なお変換できない場合は、nil を返します。
    /// - Parameter urlString: 変換するURL文字列
    /// - Returns: `URL` を返します。
    static func conformToRFC2396(urlString: String) -> URL? {
        if let url = URL(string: urlString) {
            return url
        }

        var characterSets = CharacterSet.urlHostAllowed
        characterSets.formUnion(CharacterSet.urlPathAllowed)
        characterSets.formUnion(CharacterSet.urlQueryAllowed)
        characterSets.formUnion(CharacterSet.urlFragmentAllowed)
        characterSets.formUnion(CharacterSet.urlPasswordAllowed)
        characterSets.formUnion(CharacterSet.urlUserAllowed)
        characterSets.formUnion(CharacterSet(charactersIn: "%"))
        characterSets.formUnion(CharacterSet(charactersIn: "#"))

        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: characterSets) else {
            return nil
        }

        guard let url = URL(string: encodedUrlString), url.scheme != nil else {
            return nil
        }

        return url
    }
}
