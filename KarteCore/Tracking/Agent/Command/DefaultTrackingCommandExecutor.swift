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

internal class DefaultTrackingCommandExecutor: TrackingCommandExecutor {
    weak var delegate: TrackingCommandExecutorDelegate?
    var repository: TrackingCommandRepository

    private var app: KarteApp
    private var bundler: CommandBundlerProxy

    init(app: KarteApp, queue: DispatchQueue, repository: TrackingCommandRepository) {
        let timeWindowBundleRule = TimeWindowBundleRule(queue: queue, interval: .milliseconds(100))
        TrackClient.shared.addObserver(timeWindowBundleRule)

        let bundler = CommandBundler(
            beforeBundleRules: [UserBundleRule(), SceneBundleRule()],
            afterBundleRules: [CommandCountBundleRule()],
            asyncBundleRules: [timeWindowBundleRule]
        )
        self.bundler = StateCommandBundlerProxy(bundler: bundler)
        self.repository = repository
        self.app = app

        bundler.delegate = self
    }

    func addCommand(_ command: TrackingCommand) {
        if repository.isRegistered(command: command) {
            Logger.info(tag: .track, message: "Command is already registered. command_id=\(command.identifier)")
        }
        repository.register(command: command)
        bundler.addCommand(command)
    }

    deinit {
    }
}

private extension DefaultTrackingCommandExecutor {
    func request(bundle: CommandBundle) {
        guard let request = bundle.newRequest(app: app) else {
            return
        }

        TrackClient.shared.enqueue(request: request) { result in
            switch result {
            case .success(let response):
                self.handleSuccess(request: request, response: response, bundle: bundle)

            case .failure(let error):
                self.handleFailure(request: request, error: error, bundle: bundle)
            }
        }
    }

    func handleSuccess(request: TrackRequest, response: TrackRequest.Response, bundle: CommandBundle) {
        for command in bundle.commands {
            repository.unregister(command: command)
        }

        dispatch(request: request, response: response)

        for command in bundle.commands {
            delegate?.trackingCommandExecutor(self, didCompleteCommand: command)
        }

        delegate?.trackingCommandExecutorDidExecuteCommands(self)
    }

    func handleFailure(request: TrackRequest, error: SessionTaskError, bundle: CommandBundle) {
        for command in bundle.commands {
            delegate?.trackingCommandExecutor(self, didFailCommand: command)
        }
        delegate?.trackingCommandExecutorDidExecuteCommands(self)
    }

    func dispatch(request: TrackRequest, response: TrackRequest.Response) {
        guard let response = response.response else {
            return
        }
        app.modules.forEach { module in
            if case let .action(module) = module {
                guard let queue = module.queue else {
                    module.receive(response: response, request: request)
                    return
                }
                queue.async {
                    module.receive(response: response, request: request)
                }
            }
        }
    }
}

extension DefaultTrackingCommandExecutor: CommandBundlerDelegate {
    func commandBundler(_ bundler: CommandBundler, didFinishBundle bundle: CommandBundle) {
        request(bundle: bundle)
    }
}
