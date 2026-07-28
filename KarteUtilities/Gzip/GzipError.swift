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

public struct GzipError: Error, Sendable {
    public let kind: Kind
    public let message: String

    public enum Kind: Sendable, Equatable {
        case stream
        case data
        case memory
        case buffer
        case version
        case needDict
        case unknown(code: Int)
    }

    public var localizedDescription: String {
        message
    }

    init(code: Int32, msg: UnsafePointer<CChar>?) {
        switch code {
        case Z_STREAM_ERROR:
            self.kind = .stream
        case Z_DATA_ERROR:
            self.kind = .data
        case Z_MEM_ERROR:
            self.kind = .memory
        case Z_BUF_ERROR:
            self.kind = .buffer
        case Z_VERSION_ERROR:
            self.kind = .version
        case Z_NEED_DICT:
            self.kind = .needDict
        default:
            self.kind = .unknown(code: Int(code))
        }

        if let msg = msg, let message = String(validatingUTF8: msg) {
            self.message = message
        } else {
            self.message = "Unknown gzip error"
        }
    }
}
