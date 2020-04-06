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

public struct FileSource: DataSource {
    var fileURL: URL

    public var isExist: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    public init(_ fileURL: URL) {
        self.fileURL = fileURL
    }

    public func read() throws -> Data {
        try Data(contentsOf: fileURL)
    }

    public func write(_ data: Data) throws {
        try data.write(to: fileURL, options: [])
    }

    public func delete() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}
