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

internal class RetryTrackingCommandExecutor: TrackingCommandExecutor {
    weak var delegate: TrackingCommandExecutorDelegate?
    var repository: TrackingCommandRepository

    private var app: KarteApp
    private var bundler: CommandBundlerProxy

    init(app: KarteApp, queue: DispatchQueue, repository: TrackingCommandRepository) {
        let timeWindowBundleRule = TimeWindowBundleRule(queue: queue, interval: .seconds(1))
        TrackClient.shared.addObserver(timeWindowBundleRule)

        let bundler = CommandBundler(
            beforeBundleRules: [UserBundleRule(), SceneBundleRule()],
            afterBundleRules: [CommandCountBundleRule()],
            asyncBundleRules: [timeWindowBundleRule]
        )
        self.bundler = ThroughCommandBundlerProxy(bundler: bundler)
        self.repository = repository
        self.app = app

        bundler.delegate = self
    }

    func addCommand(_ command: TrackingCommand) {
        var command = command
        command.isRetry = true

        bundler.addCommand(command)
    }

    deinit {
    }
}

private extension RetryTrackingCommandExecutor {
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
}

extension RetryTrackingCommandExecutor: CommandBundlerDelegate {
    func commandBundler(_ bundler: CommandBundler, didFinishBundle bundle: CommandBundle) {
        request(bundle: bundle)
    }
}
