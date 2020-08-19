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

import Quick
import Nimble
@testable import KarteUtilities
@testable import KarteCore

class TrackingCommandRepositorySpec: QuickSpec {
    func newTrackingCommandRepository() -> TrackingCommandRepository {
        DefaultTrackingCommandRepository(SQLiteDatabase(name: "karte.sqlite"))
    }
    
    override func spec() {
        var repository: TrackingCommandRepository!
        
        beforeEach {
            repository = self.newTrackingCommandRepository()
        }
        
        afterEach {
            repository.unregisterAll()
        }
        
        describe("a tracking command repository") {
            describe("its register") {
                context("command is retryable") {
                    beforeEach {
                        let event = Event(eventName: EventName("test"))
                        let command = buildCommand(event: event)
                        repository.register(command: command)
                    }
                    
                    it("commands count is 1") {
                        let commands = repository.commands
                        expect(commands.count).to(equal(1))
                    }
                    
                    it("event name is test") {
                        let commands = repository.commands
                        expect(commands.first?.event.eventName).to(equal(EventName("test")))
                    }
                }
                
                context("command is not retryable") {
                    beforeEach {
                        let event = Event(.fetchVariables)
                        let command = buildCommand(event: event)
                        repository.register(command: command)
                    }
                    
                    it("commands count is 0") {
                        let commands = repository.commands
                        expect(commands.count).to(equal(0))
                    }
                }
            }
            
            describe("its is registered") {
                var command: TrackingCommand!
                
                beforeEach {
                    let event = Event(eventName: EventName("test"))
                    command = buildCommand(event: event)
                    repository.register(command: command)
                }
                
                context("same command") {
                    it("result is true") {
                        expect(repository.isRegistered(command: command)).to(beTrue())
                    }
                }
                
                context("defferent command") {
                    it("result is false") {
                        let event = Event(eventName: EventName("test"))
                        let command2 = buildCommand(event: event)
                        expect(repository.isRegistered(command: command2)).to(beFalse())
                    }
                }
            }
            
            describe("its unregister") {
                var command: TrackingCommand!
                
                beforeEach {
                    let event = Event(eventName: EventName("test"))
                    command = buildCommand(event: event)
                    repository.register(command: command)
                }
                
                context("same command") {
                    it("commands count is 0") {
                        repository.unregister(command: command)
                        
                        let commands = repository.commands
                        expect(commands.count).to(equal(0))
                    }
                }
                
                context("defferent command") {
                    it("commands count is 1") {
                        let event = Event(eventName: EventName("test"))
                        let command2 = buildCommand(event: event)
                        repository.unregister(command: command2)
                        
                        let commands = repository.commands
                        expect(commands.count).to(equal(1))
                    }
                }
            }
            
            describe("its retryableCommands") {
                beforeEach {
                    let event = Event(eventName: EventName("test"))
                    let command = buildCommand(event: event)
                    repository.register(command: command)
                }
                
                context("same process") {
                    it("commands count is 0") {
                        let commands = repository.retryableCommands
                        expect(commands.count).to(equal(0))
                    }
                }
                
                context("different process") {
                    it("commands count is 1") {
                        let commands = self.newTrackingCommandRepository().retryableCommands
                        expect(commands.count).to(equal(1))
                    }
                }
            }
        }
    }
}
