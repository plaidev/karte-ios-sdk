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
    var queue: DispatchQueue!

    override func setUp() {
        super.setUp()
        provider = CommandBundlerApplicationStateProviderMock()
        queue = DispatchQueue(label: "io.karte.test.CommandBundlerProxySpec")

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

        let proxy = StateCommandBundlerProxy(bundler: spy, queue: queue)
        queue.sync {
            proxy.addCommand(buildCommand(event: Event(.open)))
            proxy.addCommand(buildCommand())
        }

        XCTAssertEqual(spy.commands.count, 2, "All commands should pass through when active")
    }

    func testInactivePassesThrough() {
        provider.state = .inactive
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy, queue: queue)
        queue.sync {
            proxy.addCommand(buildCommand(event: Event(.open)))
            proxy.addCommand(buildCommand())
        }

        XCTAssertEqual(spy.commands.count, 2, "All commands should pass through when inactive")
    }

    func testBackgroundFiltersCommands() {
        provider.state = .background
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy, queue: queue)
        // 初期化系イベント（native_app_install / native_app_update / native_app_open / native_app_crashed）は
        // isReadyOnBackground が false になる。
        queue.sync {
            proxy.addCommand(buildCommand(event: Event(.open))) // native_app_open
            proxy.addCommand(buildCommand())
        }

        XCTAssertEqual(spy.commands.count, 1, "Only isReadyOnBackground commands should pass through when background")
        XCTAssertEqual(spy.commands.first?.event.eventName, EventName("test"), "Buffered initialization events should not reach the bundler")
    }

    // TODO: active / inactive -> background（バッファリング開始）のテストを追加する
    func testBackgroundToForegroundFlushesBuffer() {
        provider.state = .background
        let spy = CommandBundlerProxySpy()

        let proxy = StateCommandBundlerProxy(bundler: spy, queue: queue)
        queue.sync {
            proxy.addCommand(buildCommand(event: Event(.open)))
            proxy.addCommand(buildCommand(event: Event(.install)))
        }
        XCTAssertEqual(spy.commands.count, 0, "Initialization events should be buffered in background")

        provider.state = .inactive
        // provider.state の変更は queue.async で処理される。queue.sync で完了を待ってから検証する。
        queue.sync {
            XCTAssertEqual(spy.commands.count, 2, "Buffered commands should be flushed when leaving background")
        }

        queue.sync {
            proxy.addCommand(buildCommand())
        }
        XCTAssertEqual(spy.commands.count, 3, "Commands should pass through immediately when not in background")

        provider.state = .active
        queue.sync {
            proxy.addCommand(buildCommand())
        }
        XCTAssertEqual(spy.commands.count, 4, "Commands added in active state should also pass through")
    }

    // アプリケーションの状態変更時に呼ばれる addCommand と、別経路から呼ばれる addCommand が同時に走ってもクラッシュしないことを検証する。
    func testConcurrentLifecycleNotificationAndAddCommand() {
        let spy = CommandBundlerProxySpy()
        let proxy = StateCommandBundlerProxy(bundler: spy, queue: queue)

        provider.state = .background

        let iterations = 100
        let expectation = XCTestExpectation(description: "concurrent")
        expectation.expectedFulfillmentCount = iterations * 2

        for _ in 0..<iterations {
            DispatchQueue.global().async {
                // active への遷移時に bundler.addCommand が呼ばれる。
                self.provider.state = .active
                self.provider.state = .background
                expectation.fulfill()
            }
            queue.async {
                proxy.addCommand(buildCommand())
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)

        provider.state = .active
        queue.sync {
            XCTAssertEqual(spy.commands.count, iterations, "All commands should be delivered without crashing")
        }
    }
}
