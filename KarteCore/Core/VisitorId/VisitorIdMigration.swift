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

internal struct VisitorIdMigration: Migration {
    @Injected(name: "visitor_id_service.repository")
    var repository: Repository

    @Injected(name: "visitor_id_service.file_url")
    var fileURL: URL

    @Injected(name: "visitor_id_service.legacy_file_url")
    var legacyFileURL: URL

    var isNeedMigrate: Bool {
        FileManager.default.fileExists(atPath: legacyFileURL.path) && !FileManager.default.fileExists(atPath: fileURL.path)
    }

    func migrate() throws {
        guard let dict = NSKeyedUnarchiver.unarchiveObject(withFile: legacyFileURL.path) as? [String: Any] else {
            return
        }

        guard let visitorId = dict["visitorId"] as? String else {
            return
        }

        try repository.write(VisitorId(visitorId))
    }
}
