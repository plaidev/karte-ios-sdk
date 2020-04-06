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

internal class VersionService {
    @Injected(name: "version_service.repository")
    var repository: Repository

    @Injected(name: "version_service.migration")
    var migration: Migration

    @Injected(name: "version_service.current_version_retriever")
    var currentVersionRetriever: VersionRetriever

    var currentVersion: String?
    var previousVersion: String?

    var installationStatus: InstallationStatus {
        guard let currentVersion = currentVersion else {
            return .unknown
        }
        guard let previousVersion = previousVersion else {
            return .install
        }
        guard currentVersion == previousVersion else {
            return .update
        }
        return .unknown
    }

    init() {
        migrateIfNeeded()
        load()
    }

    func clean() {
        self.currentVersion = nil
        self.previousVersion = nil
        do {
            try repository.delete()
        } catch {
            Logger.error(tag: .core, message: "Failed to remove of version file. \(error)")
        }
    }

    deinit {
    }
}

private extension VersionService {
    func load() {
        if currentVersion != nil {
            return
        }

        if repository.isExist {
            do {
                self.previousVersion = try repository.read(Version.self).previous
            } catch {
                Logger.error(tag: .core, message: "Failed to read version. \(error)")
            }
        }

        self.currentVersion = currentVersionRetriever.version
        save()
    }

    func save() {
        guard let currentVersion = currentVersion, currentVersion != previousVersion else {
            return
        }

        do {
            try repository.write(Version(previous: currentVersion))
        } catch {
            Logger.error(tag: .core, message: "Failed to write version to file. \(error)")
        }
    }

    func migrateIfNeeded() {
        guard migration.isNeedMigrate else {
            return
        }

        do {
            try migration.migrate()
        } catch {
            Logger.error(tag: .core, message: "Failed to migrate of version file. \(error)")
        }
    }
}

extension Resolver {
    static func registerVersionService() {
        // https://developer.apple.com/documentation/foundation/filemanager/1407693-url
        // swiftlint:disable:next force_try
        let url = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = url.appendingPathComponent("karte.app.json")
        let legacyFileURL = url.appendingPathComponent("karte.app.plist")

        register(name: "version_service.current_version_retriever") {
            DefaultVersionRetriever() as VersionRetriever
        }
        register(name: "version_service.repository") {
            JSONRepository(dataSource: resolve(name: "version_service.data_source")) as Repository
        }.scope(cached)
        register(name: "version_service.data_source") {
            FileSource(resolve(name: "version_service.file_url")) as DataSource
        }.scope(cached)
        register(name: "version_service.migration") {
            VersionMigration() as Migration
        }
        register(name: "version_service.file_url") {
            fileURL
        }.scope(cached)
        register(name: "version_service.legacy_file_url") {
            legacyFileURL
        }.scope(cached)
    }
}
