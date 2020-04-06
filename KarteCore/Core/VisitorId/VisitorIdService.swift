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

internal class VisitorIdService {
    @Injected(name: "visitor_id_service.generator")
    var generator: IdGenerator

    @Injected(name: "visitor_id_service.repository")
    var repository: Repository

    @Injected(name: "visitor_id_service.migration")
    var migration: Migration

    @Injected(name: "visitor_id_service.file_url")
    var fileURL: URL

    var cachedVisitorId: String?

    var visitorId: String {
        if let visId = read() {
            return visId
        }
        return generate()
    }

    init() {
        migrateIfNeeded()
    }

    func renew() {
        let oldVisId = visitorId
        let newVisId = generate()

        Tracker(oldVisId).track(event: Event(.renewVisitorId(old: nil, new: newVisId)))
        Tracker(oldVisId).track(event: Event(.renewVisitorId(old: oldVisId, new: nil)))

        KarteApp.shared.modules.forEach { module in
            if case let .user(module) = module {
                module.renew(visitorId: newVisId, previous: oldVisId)
            }
        }
    }

    func clean() {
        self.cachedVisitorId = nil

        do {
            try repository.delete()
        } catch {
            Logger.error(tag: .core, message: "Failed to remove of karte.user.json file. \(error)")
        }
    }

    deinit {
    }
}

private extension VisitorIdService {
    func generate() -> String {
        let visId = generator.generate()
        write(visId)
        return visId
    }

    private func read() -> String? {
        if let visId = cachedVisitorId {
            return visId
        }

        if repository.isExist {
            do {
                let visId = try repository.read(VisitorId.self).visitorId
                self.cachedVisitorId = visId
                return visId
            } catch {
                Logger.error(tag: .core, message: "Failed to read visitor id. \(error)")
            }
        }

        return nil
    }

    func write(_ visId: String) {
        self.cachedVisitorId = visId

        do {
            try repository.write(VisitorId(visId))
        } catch {
            Logger.error(tag: .core, message: "Failed to write visitor id. \(error)")
        }
    }

    func migrateIfNeeded() {
        guard migration.isNeedMigrate else {
            return
        }

        do {
            try migration.migrate()
        } catch {
            Logger.error(tag: .core, message: "Failed to migrate of visitor id file. \(error)")
        }
    }
}

extension Resolver {
    static func registerVisitorIdService() {
        // https://developer.apple.com/documentation/foundation/filemanager/1407693-url
        // swiftlint:disable:next force_try
        let url = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let fileURL = url.appendingPathComponent("karte.user.json")
        let legacyFileURL = url.appendingPathComponent("karte.user.plist")

        register(name: "visitor_id_service.generator") {
            VisitorIdGenerator() as IdGenerator
        }
        register(name: "visitor_id_service.repository") {
            JSONRepository(dataSource: resolve(name: "visitor_id_service.data_source")) as Repository
        }.scope(cached)
        register(name: "visitor_id_service.data_source") {
            FileSource(resolve(name: "visitor_id_service.file_url")) as DataSource
        }.scope(cached)
        register(name: "visitor_id_service.migration") {
            VisitorIdMigration() as Migration
        }
        register(name: "visitor_id_service.file_url") {
            fileURL
        }.scope(cached)
        register(name: "visitor_id_service.legacy_file_url") {
            legacyFileURL
        }.scope(cached)
    }
}
