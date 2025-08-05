//
//  Copyright 2025 PLAID, Inc.
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
//  NOTE: The Implementation was inspired by APIKit.

import Foundation
import MobileCoreServices

public struct MultipartFormDataBody {
    public let parts: [Part]
    public let boundary: String

    public init(
        parts: [Part],
        boundary: String
    ) {
        self.parts = parts
        self.boundary = boundary
    }

    public func asData() throws -> Data {
        var bodyData = Data()

        // 各partを処理
        for part in parts {
            // パート開始境界
            bodyData.append(Data("--\(boundary)\r\n".utf8))

            // Content-Dispositionヘッダー
            if let filename = part.fileName {
                bodyData.append(Data("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\r\n".utf8))
            } else {
                bodyData.append(Data("Content-Disposition: form-data; name=\"\(part.name)\"\r\n".utf8))
            }

            // Content-Typeヘッダー
            bodyData.append(Data("Content-Type: \(part.mimeType.rawValue)\r\n\r\n".utf8))

            // 実際のデータ
            bodyData.append(part.data)
            bodyData.append(Data("\r\n".utf8))
        }

        // 終了境界
        bodyData.append(Data("--\(boundary)--\r\n".utf8))

        return bodyData
    }
}

public extension MultipartFormDataBody {
    enum MimeType: String {
        case textPlain = "text/plain"
        case imageJpeg = "image/jpeg"
    }
    struct Part {
        public let data: Data
        public let name: String
        public let mimeType: MimeType
        public let fileName: String?

        public init(
            data: Data,
            name: String,
            mimeType: MimeType = .textPlain,
            fileName: String? = nil
        ) {
            self.data = data
            self.name = name
            self.mimeType = mimeType
            self.fileName = (mimeType == .imageJpeg) ? (fileName ?? "image") : fileName
        }
    }
}
