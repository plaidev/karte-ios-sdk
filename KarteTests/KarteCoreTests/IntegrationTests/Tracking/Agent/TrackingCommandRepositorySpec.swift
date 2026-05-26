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

import XCTest
@testable import KarteUtilities
@testable import KarteCore

class TrackingCommandRepositorySpec: XCTestCase {
    private var repository: TrackingCommandRepository!

    override func setUp() {
        super.setUp()
        repository = DefaultTrackingCommandRepository(SQLiteDatabase(name: "karte.sqlite"))
    }

    override func tearDown() {
        repository.unregisterAll()
        super.tearDown()
    }

    func testRegisterRetryableCommand() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        let commands = repository.commands
        XCTAssertEqual(commands.count, 1, "commands count should be 1")
        XCTAssertEqual(commands.first?.event.eventName, EventName("test"), "event name should be test")
    }

    func testRegisterNonRetryableCommand() {
        let event = Event(.fetchVariables)
        let command = buildCommand(event: event)
        repository.register(command: command)

        let commands = repository.commands
        XCTAssertEqual(commands.count, 0, "commands count should be 0 for non-retryable event")
    }

    func testIsRegisteredWithSameCommand() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        XCTAssertTrue(repository.isRegistered(command: command), "same command should be registered")
    }

    func testIsRegisteredWithDifferentCommand() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        let event2 = Event(eventName: EventName("test"))
        let command2 = buildCommand(event: event2)
        XCTAssertFalse(repository.isRegistered(command: command2), "different command should not be registered")
    }

    func testUnregisterSameCommand() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        repository.unregister(command: command)

        let commands = repository.commands
        XCTAssertEqual(commands.count, 0, "commands count should be 0 after unregistering same command")
    }

    func testUnregisterDifferentCommand() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        let event2 = Event(eventName: EventName("test"))
        let command2 = buildCommand(event: event2)
        repository.unregister(command: command2)

        let commands = repository.commands
        XCTAssertEqual(commands.count, 1, "commands count should remain 1 after unregistering different command")
    }

    func testRetryableCommandsSameProcess() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        let commands = repository.retryableCommands
        XCTAssertEqual(commands.count, 0, "retryable commands in same process should be empty")
    }

    func testRetryableCommandsDifferentProcess() {
        let event = Event(eventName: EventName("test"))
        let command = buildCommand(event: event)
        repository.register(command: command)

        let newRepository = DefaultTrackingCommandRepository(SQLiteDatabase(name: "karte.sqlite"))
        let commands = newRepository.retryableCommands
        XCTAssertEqual(commands.count, 1, "retryable commands from different process should be 1")
    }
}
