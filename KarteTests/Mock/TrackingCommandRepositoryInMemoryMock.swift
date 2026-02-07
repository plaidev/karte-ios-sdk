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
@testable import KarteCore

class TrackingCommandRepositoryInMemoryMock: TrackingCommandRepository {
    private var storedCommands: [TrackingCommand] = []

    var table: TrackingCommandTable? { nil }

    var processId: String = UUID().uuidString

    var unprocessedCommandCount: UInt {
        UInt(storedCommands.count)
    }

    var commands: [TrackingCommand] {
        storedCommands
    }

    var retryableCommands: [TrackingCommand] {
        // テストでは前回プロセスのコマンドはないので空を返す
        []
    }

    func isRegistered(command: TrackingCommand) -> Bool {
        storedCommands.contains { $0.identifier == command.identifier }
    }

    func register(command: TrackingCommand) {
        guard command.properties.isRetryable else {
            return
        }
        storedCommands.append(command)
    }

    func unregister(command: TrackingCommand) {
        storedCommands.removeAll { $0.identifier == command.identifier }
    }

    func unregisterAll() {
        storedCommands.removeAll()
    }
}
