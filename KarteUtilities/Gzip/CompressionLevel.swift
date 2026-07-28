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

import zlib

public struct CompressionLevel: RawRepresentable, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let noCompression = CompressionLevel(rawValue: Z_NO_COMPRESSION)
    public static let bestSpeed = CompressionLevel(rawValue: Z_BEST_SPEED)
    public static let bestCompression = CompressionLevel(rawValue: Z_BEST_COMPRESSION)
    public static let defaultCompression = CompressionLevel(rawValue: Z_DEFAULT_COMPRESSION)
}
