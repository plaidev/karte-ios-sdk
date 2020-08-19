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

internal struct TrackingCommandRecord {
    var commandId: String
    var processId: String
    var data: Data
    var isReadyOnBackground: Bool
    var createdAt: Date
    var updatedAt: Date

    var parameters: [SQLiteValue] {
        [
            commandId,
            processId,
            data,
            isReadyOnBackground,
            createdAt.timeIntervalSince1970,
            updatedAt.timeIntervalSince1970
        ]
    }

    static func from(command: TrackingCommand, processId: String) -> TrackingCommandRecord? {
        guard let data = try? createJSONEncoder().encode(command) else {
            Logger.error(tag: .track, message: "TODO")
            return nil
        }
        let record = TrackingCommandRecord(
            commandId: command.identifier,
            processId: processId,
            data: data,
            isReadyOnBackground: command.properties.isReadyOnBackground,
            createdAt: command.date,
            updatedAt: command.date
        )
        return record
    }

    static func from(row: [String: SQLiteValue?]) -> TrackingCommandRecord? {
        guard let commandId = row["command_id"] as? String else {
            return nil
        }
        guard let processId = row["process_id"] as? String else {
            return nil
        }
        guard let data = row["data"] as? Data else {
            return nil
        }
        guard let isReadyOnBackground = row["is_ready_on_background"] as? Int64 else {
            return nil
        }
        guard let createdAt = row["created_at"] as? TimeInterval else {
            return nil
        }
        guard let updatedAt = row["updated_at"] as? TimeInterval else {
            return nil
        }

        let record = TrackingCommandRecord(
            commandId: commandId,
            processId: processId,
            data: data,
            isReadyOnBackground: isReadyOnBackground != 0,
            createdAt: Date(timeIntervalSince1970: createdAt),
            updatedAt: Date(timeIntervalSince1970: updatedAt)
        )
        return record
    }

    func rebuildCommand() -> TrackingCommand? {
        do {
            let command = try createJSONDecoder().decode(TrackingCommand.self, from: data)
            return command
        } catch {
            Logger.error(tag: .track, message: "TODO")
            return nil
        }
    }
}
