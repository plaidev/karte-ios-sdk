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

//
// !!!WARNING!!!
// This structure is serialized and then stored in the database.
// When adding properties, be careful not to break backwards compatibility.
//
internal struct TrackingCommand: Codable {
    struct Scene: Codable {
        var pvId: PvId
        var originalPvId: PvId
        var sceneId: SceneId
    }

    struct Properties: Codable {
        var isReadyOnBackground: Bool
        var isRetryable: Bool
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case event
        case scene
        case properties
        case visitorId
        case date
    }

    var identifier = UUID().uuidString
    var event: Event
    var scene: Scene
    var properties: Properties
    var visitorId: String
    var date: Date

    var task: TrackingTask?
    var isRetry = false
    var exponentialBackoff = ExponentialBackoff(interval: 0.5, randomFactor: 0, multiplier: 4, maxCount: 6)

    init(task: TrackingTask, scene: Scene) {
        self.event = task.event
        self.scene = scene
        self.properties = Properties(
            isReadyOnBackground: !task.event.eventName.isInitializationEvent,
            isRetryable: task.event.isRetryable
        )
        self.visitorId = task.visitorId
        self.date = task.date
        self.task = task
    }
}

extension TrackingCommand: Equatable {
    static func == (lhs: TrackingCommand, rhs: TrackingCommand) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
