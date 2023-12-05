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

public let iso8601DateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

/// JSONEncoder を返します。
/// なお dateEncodingStrategy = .secondsSince1970 が設定済みです。
public func createJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    encoder.outputFormatting = [.sortedKeys]
    return encoder
}

/// JSONDecoder を返します。
/// dateDecodingStrategy = .secondsSince1970 が設定済みです。
public func createJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return decoder
}

/// RFC2396に適合するURLに変換します。
/// なお変換できない場合は、nil を返します。
/// - Parameter urlString: 変換するURL文字列
/// - Returns: `URL` を返します。
public func conformToRFC2396(urlString: String) -> URL? {
    if #available(iOS 17.0, *) {
        if let url = URL(string: urlString, encodingInvalidCharacters: false) {
            return url
        }
    } else {
        if let url = URL(string: urlString) {
            return url
        }
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

/// Whether the receiver is compressed in gzip format.
/// - Parameter data: Check target.
/// - Returns: If it is Gzip-compressed, it returns true.
public func isGzipped(_ data: Data) -> Bool {
    data.isGzipped
}

/// Create a new `Data` instance by compressing the receiver using zlib.
/// Throws an error if compression failed.
///
/// - Parameters:
///   - data: Compression target.
///   - level: Compression level.
/// - Returns: Gzip-compressed `Data` instance.
/// - Throws: `GzipError`
public func gzipped(_ data: Data, level: CompressionLevel = .defaultCompression) throws -> Data {
    try data.gzipped(level: level)
}

/// メソッドのセレクタに対応する実装を交換します。
/// - Parameters:
///   - cls: 交換対象のクラス
///   - from: 交換元のセレクタ
///   - to: 交換先のセレクタ
public func exchangeInstanceMethod(cls: AnyClass?, from: Selector, to: Selector) {
    // swiftlint:disable:previous identifier_name
    let fromMethod = class_getInstanceMethod(cls, from)
    let toMethod = class_getInstanceMethod(cls, to)

    if let fromMethod = fromMethod, let toMethod = toMethod {
        method_exchangeImplementations(fromMethod, toMethod)
    }
}
