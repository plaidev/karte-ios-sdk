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

class CommandBundlerProxySpy: CommandBundler {
    var commands = [TrackingCommand]()

    init() {
        super.init(beforeBundleRules: [], afterBundleRules: [], asyncBundleRules: [])
    }

    override func addCommand(_ command: TrackingCommand) {
        commands.append(command)
    }
}

final class CommandBundlerProxySpec: XCTestCase {
    var provider: CommandBundlerApplicationStateProviderMock!

    override func setUp() {
        super.setUp()
        provider = CommandBundlerApplicationStateProviderMock()

        Resolver.root = Resolver.submock
        let currentProvider = provider!
        Resolver.root.register {
            currentProvider as CommandBundlerApplicationStateProvider
        }
    }

    override func tearDown() {
        Resolver.root = Resolver.mock
        super.tearDown()
    }

    func testActivePassesThrough() {
        provider.state = .active
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy)
        proxy.addCommand(buildCommand(event: Event(.open)))
        proxy.addCommand(buildCommand())

        XCTAssertEqual(spy.commands.count, 2, "All commands should pass through when active")
    }

    func testInactivePassesThrough() {
        provider.state = .inactive
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy)
        proxy.addCommand(buildCommand(event: Event(.open)))
        proxy.addCommand(buildCommand())

        XCTAssertEqual(spy.commands.count, 2, "All commands should pass through when inactive")
    }

    func testBackgroundFiltersCommands() {
        provider.state = .background
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy)
        proxy.addCommand(buildCommand(event: Event(.open)))
        proxy.addCommand(buildCommand())

        XCTAssertEqual(spy.commands.count, 1, "Only isReadyOnBackground commands should pass through when background")
    }

    func testBackgroundToForegroundFlushesBuffer() async {
        provider.state = .background
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy)
        proxy.addCommand(buildCommand(event: Event(.open)))
        proxy.addCommand(buildCommand(event: Event(.install)))

        try? await Task.sleep(nanoseconds: 200_000_000)
        provider.state = .inactive
        proxy.addCommand(buildCommand())

        try? await Task.sleep(nanoseconds: 200_000_000)
        provider.state = .active
        proxy.addCommand(buildCommand())

        XCTAssertEqual(spy.commands.count, 4, "Buffered commands should be flushed when returning to foreground")
    }
}
