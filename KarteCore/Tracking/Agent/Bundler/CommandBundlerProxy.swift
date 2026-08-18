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

import KarteUtilities
import UIKit

internal protocol CommandBundlerProxy {
    var bundler: CommandBundler? { get }
    func addCommand(_ command: TrackingCommand)
}

internal class ThroughCommandBundlerProxy: CommandBundlerProxy {
    var bundler: CommandBundler?

    init(bundler: CommandBundler) {
        self.bundler = bundler
    }

    func addCommand(_ command: TrackingCommand) {
        bundler?.addCommand(command)
    }

    deinit {
    }
}

internal class StateCommandBundlerProxy: CommandBundlerProxy {
    var bundler: CommandBundler?

    @Injected
    var provider: any CommandBundlerApplicationStateProvider

    private let queue: DispatchQueue

    var state = UIApplication.shared.applicationState
    var commands = [TrackingCommand]()

    init(bundler: CommandBundler, queue: DispatchQueue) {
        self.bundler = bundler
        self.queue = queue
        self.provider.delegate = self
    }

    func addCommand(_ command: TrackingCommand) {
        guard state != .background || command.properties.isReadyOnBackground else {
            return commands.append(command)
        }
        bundler?.addCommand(command)
    }

    deinit {
    }
}

extension StateCommandBundlerProxy: CommandBundlerApplicationStateProviderDelegate {
    func commandBundlerApplicationStateProvider(_ provider: any CommandBundlerApplicationStateProvider, didChangeApplicationState applicationState: UIApplication.State) {
        queue.async { [weak self] in
            self?.handleApplicationStateChange(applicationState)
        }
    }
}

private extension StateCommandBundlerProxy {
    func handleApplicationStateChange(_ applicationState: UIApplication.State) {
        state = applicationState

        guard applicationState != .background else {
            return
        }

        while !commands.isEmpty {
            let command = commands.removeFirst()
            bundler?.addCommand(command)
        }
    }
}

extension Resolver {
    static func registerApplicationStateProvider() {
        register { DefaultCommandBundlerApplicationStateProvider() as any CommandBundlerApplicationStateProvider }
    }
}
