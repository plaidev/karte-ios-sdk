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

class CommandBundlerProxySpy: CommandBundler {
    var commands = [TrackingCommand]()

    init() {
        super.init(beforeBundleRules: [], afterBundleRules: [], asyncBundleRules: [])
    }

    override func addCommand(_ command: TrackingCommand) {
        commands.append(command)
    }
}

class CommandBundlerProxySpec: AsyncSpec {
    override class func spec() {
        var provider: CommandBundlerApplicationStateProviderMock!

        beforeSuite {
            provider = CommandBundlerApplicationStateProviderMock()

            Resolver.root = Resolver.submock
            Resolver.root.register {
                provider as CommandBundlerApplicationStateProvider
            }
        }

        afterSuite {
            Resolver.root = Resolver.mock
        }

        describe("a command bundler proxy") {
            context("when active") {
                var spy: CommandBundlerProxySpy!

                beforeEach {
                    provider.state = .active
                    spy = CommandBundlerProxySpy()

                    let proxy = StateCommandBundlerProxy(bundler: spy)
                    proxy.addCommand(buildCommand(event: Event(.open)))
                    proxy.addCommand(buildCommand())
                }

                it("commands count is 2") {
                    expect(spy.commands.count).to(equal(2))
                }
            }

            context("when inactive") {
                var spy: CommandBundlerProxySpy!

                beforeEach {
                    provider.state = .inactive
                    spy = CommandBundlerProxySpy()

                    let proxy = StateCommandBundlerProxy(bundler: spy)
                    proxy.addCommand(buildCommand(event: Event(.open)))
                    proxy.addCommand(buildCommand())
                }

                it("commands count is 0") {
                    expect(spy.commands.count).to(equal(2))
                }
            }

            context("when background") {
                var spy: CommandBundlerProxySpy!

                beforeEach {
                    provider.state = .background
                    spy = CommandBundlerProxySpy()

                    let proxy = StateCommandBundlerProxy(bundler: spy)
                    proxy.addCommand(buildCommand(event: Event(.open)))
                    proxy.addCommand(buildCommand())
                }

                it("commands count is 0") {
                    expect(spy.commands.count).to(equal(1))
                }
            }

            context("when background to inactive to active") {
                it("commands count is 4") {
                    provider.state = .background
                    let spy = CommandBundlerProxySpy()

                    let proxy = StateCommandBundlerProxy(bundler: spy)
                    proxy.addCommand(buildCommand(event: Event(.open)))
                    proxy.addCommand(buildCommand(event: Event(.install)))

                    try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
                    provider.state = .inactive
                    proxy.addCommand(buildCommand())

                    try? await Task.sleep(nanoseconds: 200_000_000) // 200ms more
                    provider.state = .active
                    proxy.addCommand(buildCommand())

                    expect(spy.commands.count).to(equal(4))
                }
            }
        }
    }
}
