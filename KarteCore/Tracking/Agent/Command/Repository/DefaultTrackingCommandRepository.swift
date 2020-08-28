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

internal class DefaultTrackingCommandRepository: TrackingCommandRepository {
    private var schema: TrackingCommandTableSchema

    var table: TrackingCommandTable? {
        do {
            try schema.create()
        } catch {
            Logger.error(tag: .track, message: "The table could not be created: \(schema.name) / \(error.localizedDescription)")
            return nil
        }
        return TrackingCommandTable(schema)
    }

    var processId: String

    var unprocessedCommandCount: UInt {
        let statement = "SELECT COUNT(*) AS count FROM \(schema.name) WHERE created_at > ?;"
        do {
            guard let row = try table?.query(statement, parameters: [limit]).first else {
                return 0
            }
            guard let count = row["count"] as? Int64 else {
                return 0
            }
            return UInt(count)
        } catch {
            return 0
        }
    }

    var commands: [TrackingCommand] {
        let statement = "SELECT * FROM \(schema.name) WHERE created_at > ?;"
        return fetchCommands(statement: statement, parameters: [limit])
    }

    var retryableCommands: [TrackingCommand] {
        let statement = "SELECT * FROM \(schema.name) WHERE process_id != ? AND created_at > ?;"
        return fetchCommands(statement: statement, parameters: [processId, limit])
    }

    var limit: Date {
        Date().addingTimeInterval(-60 * 60 * 24 * 30)
    }

    init(_ database: SQLiteDatabase) {
        self.schema = TrackingCommandTableSchema(database)
        self.processId = UUID().uuidString
    }

    func isRegistered(command: TrackingCommand) -> Bool {
        guard let table = table else {
            return false
        }

        let statement = "SELECT * FROM \(schema.name) WHERE command_id = ?;"
        let rows: [[String: SQLiteValue?]]
        do {
            rows = try table.query(statement, parameters: [command.identifier])
        } catch {
            Logger.error(tag: .track, message: "The query execution failed: \(statement) / \(error.localizedDescription)")
            return false
        }

        let records = rows.compactMap { row -> TrackingCommandRecord? in
            let record = TrackingCommandRecord.from(row: row)
            return record
        }
        return !records.isEmpty
    }

    func register(command: TrackingCommand) {
        guard command.properties.isRetryable else {
            return
        }
        guard let table = table, let record = TrackingCommandRecord.from(command: command, processId: processId) else {
            return
        }

        let parameters = record.parameters
        let placeholders = parameters.map { _ in
            "?"
        }.joined(separator: ", ")

        let statement = "INSERT INTO \(schema.name) VALUES(\(placeholders));"
        do {
            try table.queryUpdate(statement, parameters: record.parameters)
            Logger.verbose(tag: .track, message: "Did insert record. command_id=\(record.commandId)")
        } catch {
            Logger.error(tag: .track, message: "Failed to insert record: \(record.commandId) / \(error.localizedDescription)")
        }
    }

    func unregister(command: TrackingCommand) {
        guard let table = table else {
            return
        }

        let statement = "DELETE FROM \(schema.name) WHERE command_id = ?;"
        do {
            try table.queryUpdate(statement, parameters: [command.identifier])
            Logger.debug(tag: .track, message: "Did delete record. command_id=\(command.identifier)")
        } catch {
            Logger.error(tag: .track, message: "Failed to delete record: command_id=\(command.identifier) / \(error.localizedDescription)")
        }
    }

    func unregisterAll() {
        guard let table = table else {
            return
        }

        let statement = "DELETE FROM \(schema.name);"
        do {
            try table.queryUpdate(statement, parameters: [])
            Logger.debug(tag: .track, message: "Did delete all records.")
        } catch {
            Logger.error(tag: .track, message: "Failed to delete all records: \(error.localizedDescription)")
        }
    }

    deinit {
    }
}

private extension DefaultTrackingCommandRepository {
    func fetchCommands(statement: String, parameters: [SQLiteValue]) -> [TrackingCommand] {
        guard let table = table else {
            return []
        }

        let rows: [[String: SQLiteValue?]]
        do {
            rows = try table.query(statement, parameters: parameters)
        } catch {
            Logger.error(tag: .track, message: "The query execution failed: \(statement) / \(error.localizedDescription)")
            return []
        }

        let commands = rows.compactMap { row -> TrackingCommand? in
            let command = TrackingCommandRecord.from(row: row)?.rebuildCommand()
            return command
        }
        return commands
    }
}
