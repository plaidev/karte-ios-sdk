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

internal class CommandBundle {
    private (set) var commands = [TrackingCommand]()
    private (set) var isFrozen = false

    var isEmpty: Bool {
        commands.isEmpty
    }

    var first: TrackingCommand? {
        commands.first
    }

    var last: TrackingCommand? {
        commands.last
    }

    var count: Int {
        commands.count
    }

    func addCommand(_ command: TrackingCommand) {
        commands.append(command)
    }

    func freeze() {
        // In some cases, events do not line up in order of occurrence under certain conditions, so sort them before the freeze.
        commands.sort { command1, command2 -> Bool in
            command1.date < command2.date
        }

        isFrozen = true
    }

    func newRequest(app: KarteApp) -> TrackRequest? {
        TrackRequest(app: app, commands: commands)
    }

    deinit {
    }
}

extension CommandBundle: Equatable {
    static func == (lhs: CommandBundle, rhs: CommandBundle) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
