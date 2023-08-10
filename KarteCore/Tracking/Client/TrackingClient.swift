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

internal class TrackingClient {
    weak var delegate: TrackerDelegate?

    private var coreService: CoreService
    private var agent: TrackingAgent
    private var lifecycleObserver: ApplicationLifecycleObserver
    lazy var eventRejectionFilter: TrackEventRejectionFilter = {
        var filter = TrackEventRejectionFilter()
        KarteApp.shared.modules.flatMap { module -> [TrackEventRejectionFilterRule] in
            guard case let .track(module) = module else {
                return []
            }
            return module.provideEventRejectionFilterRules()
        }.forEach { rule in
            filter.add(rule: rule)
        }
        return filter
    }()

    init(app: KarteApp, core: CoreService) {
        self.agent = TrackingAgent(app: app)
        self.coreService = core
        self.lifecycleObserver = ApplicationLifecycleObserver()

        observe()
    }

    func track(task: TrackingTask) {
        guard !coreService.isOptOut else {
            return task.resolve()
        }
        guard filter(event: task.event) else {
            return task.reject()
        }

        if Thread.isMainThread {
            request(task: task)
        } else {
            DispatchQueue.main.async {
                self.request(task: task)
            }
        }
    }

    func trackInitialEvents() {
        switch coreService.versionService.installationStatus {
        case .install:
            track(task: TrackingTask(event: Event(.install)))

        case .update:
            let event = Event(.update(version: coreService.versionService.previousVersion))
            track(task: TrackingTask(event: event))

        case .unknown:
            break
        }
        track(task: TrackingTask(event: Event(.open)))
    }

    func teardown() {
        agent.teardown()
    }

    deinit {
        unobserve()
    }
}

private extension TrackingClient {
    func filter(event: Event) -> Bool {
        let filter = EventFilter.Builder()
            .add(EmptyEventNameFilterRule())
            .add(NonAsciiEventNameFilterRule())
            .add(UnretryableEventFilterRule())
            .add(InitializationEventFilterRule(), isEnabled: !coreService.configuration.isSendInitializationEventEnabled)
            .add(InvalidEventNameFilterRule())
            .add(InvalidEventFieldNameFilterRule())
            .add(InvalidEventFieldValueFilterRule())
            .build()
        do {
            try filter.filter(event)
            return true
        } catch {
            Logger.error(tag: .track, message: "Event is invalid.")
            return false
        }
    }

    func request(task: TrackingTask) {
        let command = preProcess(task: task)
        process(command: command)
    }

    func preProcess(task: TrackingTask) -> TrackingCommand {
        task.event = delegate?.intercept(task.event) ?? task.event

        let pvService = coreService.pvService
        let sceneId = SceneId(view: task.view)
        task.event = KarteApp.shared.modules.reduce(task.event) { event, module -> Event in
            if case let .track(module) = module {
                return module.prepare(event: event, sceneId: sceneId)
            }
            return event
        }
        changePvIfNeeded(task: task, pvService: pvService, sceneId: sceneId)

        let command = newCommand(task: task, pvService: pvService, sceneId: sceneId)
        return command
    }

    func process(command: TrackingCommand) {
        agent.schedule(command: command)
    }

    func changePvIfNeeded(task: TrackingTask, pvService: PvService, sceneId: SceneId) {
        guard task.event.eventName == .view else {
            return
        }
        pvService.changePv(sceneId)
    }

    func newCommand(task: TrackingTask, pvService: PvService, sceneId: SceneId) -> TrackingCommand {
        let scene = TrackingCommand.Scene(
            pvId: pvService.pvId(forSceneId: sceneId),
            originalPvId: pvService.originalPvId(forSceneId: sceneId),
            sceneId: sceneId
        )
        let command = TrackingCommand(task: task, scene: scene)
        return command
    }

    func observe() {
        lifecycleObserver.start()
    }

    func unobserve() {
        lifecycleObserver.stop()
    }
}
