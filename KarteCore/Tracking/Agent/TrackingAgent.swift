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

internal class TrackingAgent {
    static let trackingAgentHasNoCommandsNotification = Notification.Name("io.karte.tracking.agent.commands.empty")

    private let queue: DispatchQueue
    private let repository: TrackingCommandRepository
    private let circuitBreaker: CircuitBreaker

    private var defaultTrackingCommandExecutor: TrackingCommandExecutor
    private var retryTrackingCommandExecutor: TrackingCommandExecutor
    private var backgroundTask: BackgroundTask

    init(app: KarteApp) {
        let queue = DispatchQueue(
            label: "io.karte.tracking.agent",
            qos: .utility
        )
        TrackClient.shared.configure(app: app, callbackQueue: queue)

        let database = SQLiteDatabase(name: "karte.sqlite")
        let repository = DefaultTrackingCommandRepository(database)

        self.queue = queue
        self.repository = repository
        self.circuitBreaker = Resolver.resolve()

        self.defaultTrackingCommandExecutor = DefaultTrackingCommandExecutor(
            app: app,
            queue: queue,
            repository: repository
        )
        self.retryTrackingCommandExecutor = RetryTrackingCommandExecutor(
            app: app,
            queue: queue,
            repository: repository
        )
        self.backgroundTask = BackgroundTask()

        self.defaultTrackingCommandExecutor.delegate = self
        self.retryTrackingCommandExecutor.delegate = self
        self.backgroundTask.delegate = self

        observe()
        restoreRetryableCommands()
    }

    func schedule(command: TrackingCommand) {
        queue.async { [weak self] in
            self?.defaultTrackingCommandExecutor.addCommand(command)
        }
    }

    func teardown() {
        repository.unregisterAll()
        TrackClient.shared.teardown()
    }

    deinit {
        unobserve()
    }
}

private extension TrackingAgent {
    func restoreRetryableCommands() {
        for command in repository.retryableCommands {
            queue.async { [weak self] in
                self?.retryTrackingCommandExecutor.addCommand(command)
            }
        }
    }

    func observe() {
        backgroundTask.observeLifecycle()
    }

    func unobserve() {
        backgroundTask.unobserveLifecycle()
    }
}

extension TrackingAgent: TrackingCommandExecutorDelegate {
    func trackingCommandExecutor(_ executor: TrackingCommandExecutor, didCompleteCommand command: TrackingCommand) {
        command.task?.resolve()
        circuitBreaker.reset()
    }

    func trackingCommandExecutor(_ executor: TrackingCommandExecutor, didFailCommand command: TrackingCommand) {
        circuitBreaker.countFailure()
        var command = command
        command.task?.reject()
        command.task = nil

        guard command.properties.isRetryable && circuitBreaker.canRequest else {
            return
        }
        do {
            let deadline = try command.exponentialBackoff.nextDelay()
            queue.asyncAfter(deadline: .now() + deadline) { [weak self] in
                self?.retryTrackingCommandExecutor.addCommand(command)
            }
        } catch {
            Logger.warn(tag: .track, message: "The maximum number of retries has been reached.")
        }
    }

    func trackingCommandExecutorDidExecuteCommands(_ executor: TrackingCommandExecutor) {
        guard repository.unprocessedCommandCount == 0 else {
            return
        }
        backgroundTask.finish()

        let notification = Notification(name: type(of: self).trackingAgentHasNoCommandsNotification)
        NotificationCenter.default.post(notification)
    }
}

extension TrackingAgent: BackgroundTaskDelegate {
    func backgroundTaskShouldStart(_ backgroundTask: BackgroundTask) -> Bool {
        repository.unprocessedCommandCount > 0
    }

    func backgroundTaskWillStart(_ backgroundTask: BackgroundTask) {
        Logger.debug(tag: .track, message: "Start sending events in the background because there are unsent events.")
    }

    func backgroundTaskDidFinish(_ backgroundTask: BackgroundTask) {
        Logger.debug(tag: .track, message: "Ends the sending of unsent events.")
    }
}

extension Resolver {
    static func registerCircuitBreaker() {
        register { CircuitBreaker() }
    }
}
