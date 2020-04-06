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

internal class DefaultPubSubRepository: PubSubRepository {
    private var schema: PubSubTableSchema

    var table: PubSubTable? {
        do {
            try schema.create()
        } catch {
            Logger.error(tag: .track, message: "The table could not be created: \(schema.name) / \(error.localizedDescription)")
            return nil
        }
        return PubSubTable(schema)
    }

    var count: Int {
        let statement = "SELECT COUNT(*) AS count FROM \(schema.name) WHERE created_at > ?;"
        do {
            guard let row = try table?.query(statement, parameters: [limit]).first else {
                return 0
            }
            guard let count = row["count"] as? Int64 else {
                return 0
            }
            return Int(count)
        } catch {
            return 0
        }
    }

    var limit: Date {
        Date().addingTimeInterval(-60 * 60 * 24 * 30)
    }

    init(_ database: SQLiteDatabase) {
        self.schema = PubSubTableSchema(database)
    }

    func retryable(publisherId: PubSubPublisherId, processId: String) -> [PubSubMessage] {
        guard let table = table else {
            return []
        }

        let statement = "SELECT * FROM \(schema.name) WHERE publisher_id = ? AND process_id != ? AND created_at > ?;"
        let rows: [[String: SQLiteValue?]]
        do {
            rows = try table.query(statement, parameters: [publisherId.id, processId, limit])
        } catch {
            Logger.error(tag: .track, message: "The query execution failed: \(statement) / \(error.localizedDescription)")
            return []
        }

        let elements = rows.compactMap { row -> PubSubMessage? in
            let message = PubSubMessage.from(row)
            return message
        }
        return elements
    }

    func isAccepted(messageId: PubSubMessageId) -> Bool {
        guard let table = table else {
            return false
        }
        let statement = "SELECT * FROM \(schema.name) WHERE message_id = ?;"
        let rows: [[String: SQLiteValue?]]
        do {
            rows = try table.query(statement, parameters: [messageId.id])
        } catch {
            Logger.error(tag: .track, message: "The query execution failed: \(statement) / \(error.localizedDescription)")
            return false
        }
        let elements = rows.compactMap { row -> PubSubMessage? in
            let message = PubSubMessage.from(row)
            return message
        }
        return !elements.isEmpty
    }

    func accept(message: PubSubMessage, processId: String) {
        guard let table = table else {
            return
        }

        let parameters: [SQLiteValue] = [
            message.messageId.id,
            message.publisherId.id,
            processId,
            message.data,
            message.isReadyOnBackground,
            message.createdAt.timeIntervalSince1970,
            message.updatedAt.timeIntervalSince1970
        ]
        let statement = "INSERT INTO \(schema.name) VALUES(?, ?, ?, ?, ?, ?, ?);"
        do {
            try table.queryUpdate(statement, parameters: parameters)
            Logger.verbose(tag: .track, message: "Did insert record. message_id=\(message.messageId.id)")
        } catch {
            Logger.error(tag: .track, message: "Failed to insert record: \(message.messageId.id) / \(error.localizedDescription)")
        }
    }

    func remove(messageId: PubSubMessageId) {
        guard let table = table else {
            return
        }

        let statement = "DELETE FROM \(schema.name) WHERE message_id = ?;"
        do {
            try table.queryUpdate(statement, parameters: [messageId.id])
            Logger.debug(tag: .track, message: "Did delete record. message_id=\(messageId.id)")
        } catch {
            Logger.error(tag: .track, message: "Failed to delete record: message_id=\(messageId.id) / \(error.localizedDescription)")
        }
    }

    func removeAll() {
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
