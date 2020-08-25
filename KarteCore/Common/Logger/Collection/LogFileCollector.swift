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
import KarteUtilities

internal class LogFileCollector {
    /// Synchronous upload
    func collect(_ files: [URL]) {
        let group = DispatchGroup()
        files.forEach { file in
            guard let datePrefix = file.lastPathComponent.components(separatedBy: "_").first else {
                return
            }
            group.enter()
            Session.send(GetLogUploadURLRequest(app: KarteApp.shared, datePrefix: datePrefix)) {
                switch $0 {
                case let .success(response):
                    guard let url = response.url else {
                        try? FileManager.default.removeItem(at: file)
                        group.leave()
                        break
                    }
                    Session.send(UploadLogRequest(url: url, file: file)) {
                        switch $0 {
                        case .success:
                            try? FileManager.default.removeItem(at: file)

                        case .failure:
                            break
                        }
                        group.leave()
                    }

                case .failure:
                    group.leave()
                }
            }
        }
        group.wait()
    }
    deinit {}
}
