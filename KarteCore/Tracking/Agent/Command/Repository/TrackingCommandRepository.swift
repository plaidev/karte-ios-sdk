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

internal protocol TrackingCommandRepository {
    var table: TrackingCommandTable? { get }
    var processId: String { get }
    var unprocessedCommandCount: UInt { get }
    var commands: [TrackingCommand] { get }
    var retryableCommands: [TrackingCommand] { get }

    func isRegistered(command: TrackingCommand) -> Bool
    func register(command: TrackingCommand)
    func unregister(command: TrackingCommand)
    func unregisterAll()
}
