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

internal class TrackingService {
    @Injected
    var reachabilityService: ReachabilityService

    var coreService: CoreService
    var trackingTaskCache: TrackingTaskCache
    var lifecycleObserver: ApplicationLifecycleObserver
    var publisher: PubSubPublisher
    var pubsub: PubSub

    weak var delegate: TrackerDelegate?

    init(app: KarteApp, core: CoreService) {
        self.coreService = core
        self.trackingTaskCache = TrackingTaskCache()
        self.lifecycleObserver = ApplicationLifecycleObserver()
        self.publisher = DefaultPubSubPublisher()
        self.pubsub = DefaultPubSub()

        publisher.delegate = self
        pubsub.regist(publisher: publisher)
        pubsub.regist(subscriber: DefaultPubSubSubscriber(app: app), topic: .default)
        pubsub.regist(subscriber: RetryPubSubSubscriber(app: app), topic: .retry)

        reachabilityService.whenReachable = { [weak self] in
            Logger.info(tag: .track, message: "Communication is possible.")
            self?.pubsub.isSuspend = false
        }
        reachabilityService.whenUnreachable = { [weak self] in
            Logger.info(tag: .track, message: "Communication is impossible.")
            self?.pubsub.isSuspend = true
        }
        reachabilityService.startNotifier()

        lifecycleObserver.start()
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

    func track(task: TrackingTask) {
        if coreService.isOptOut {
            task.resolve()
            return
        }

        guard filter(event: task.event) else {
            task.reject()
            return
        }

        if Thread.isMainThread {
            publish(task: task)
        } else {
            DispatchQueue.main.async {
                self.publish(task: task)
            }
        }
    }

    deinit {
        reachabilityService.stopNotifier()
        lifecycleObserver.stop()
    }
}

internal extension TrackingService {
    func publish(task: TrackingTask) {
        task.event = delegate?.intercept(task.event) ?? task.event

        let data: Data
        do {
            data = try convert(task: task)
        } catch {
            task.reject()
            return
        }

        let message = PubSubMessage(
            messageId: PubSubMessageId(),
            publisherId: publisher.id,
            isReadyOnBackground: !task.event.eventName.isInitializationEvent,
            isRetryable: task.event.isRetryable,
            data: data,
            createdAt: task.date,
            updatedAt: task.date
        )
        trackingTaskCache.addCache(task, forKey: message.messageId)
        publisher.publish(to: pubsub, topic: .default, message: message)
    }

    func convert(task: TrackingTask) throws -> Data {
        let event = task.event

        let pvService = coreService.pvService
        let sceneId = SceneId(view: task.view)
        if event.eventName == .view {
            pvService.changePv(sceneId)
        }

        let attrs = TrackingData.Attributions(
            visitorId: task.visitorId,
            pvId: pvService.pvId(forSceneId: sceneId),
            originalPvId: pvService.originalPvId(forSceneId: sceneId),
            sceneId: sceneId,
            date: task.date
        )

        let data = TrackingData(event: event, attributions: attrs)
        return try createJSONEncoder().encode(data)
    }

    func filter(event: Event) -> Bool {
        let filter = EventFilter.Builder()
            .add(EmptyEventNameFilterRule())
            .add(NonAsciiEventNameFilterRule())
            .add(InitializationEventFilterRule(), isEnabled: !coreService.configuration.isSendInitializationEventEnabled)
            .build()
        do {
            try filter.filter(event)
            return true
        } catch {
            Logger.error(tag: .track, message: "Event is invalid.")
            return false
        }
    }

    func teardown() {
        pubsub.teardown()
    }
}

extension TrackingService: PubSubPublisherDelegate {
    func publisher(_ publisher: PubSubPublisher, didReceive message: PubSubMessage, error: Error?) {
        guard let task = trackingTaskCache.removeCache(forKey: message.messageId) else {
            return
        }
        if error == nil {
            task.resolve()
        } else {
            task.reject()
        }
    }
}

extension Resolver {
    static func  registerTrackingService() {
        register { DefaultReachabilityService(baseURL: KarteApp.configuration.baseURL) as ReachabilityService }
    }
}
