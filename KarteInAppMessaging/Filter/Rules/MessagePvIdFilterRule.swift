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
import KarteCore

internal struct MessagePvIdFilterRule: MessageFilterRule {
    var request: TrackRequest
    var app: KarteApp?

    init(request: TrackRequest, app: KarteApp?) {
        self.request = request
        self.app = app
    }

    func filter(_ message: TrackResponse.Response.Message) -> Bool {
        guard let isEnabled = message.campaign.bool(forKey: "native_app_display_limit_mode"), let pvService = app?.pvService, isEnabled else {
            return true
        }
        if pvService.pvId(forSceneId: request.sceneId) == request.pvId {
            return true
        }
        let match = pvService.originalPvId(forSceneId: request.sceneId) == request.pvId
        return match
    }
}
