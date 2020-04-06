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

internal enum TrackRequestConverter {
    static func convert(app: KarteApp, messages: [PubSubMessage], isRetry: Bool) -> [TrackRequest] {
        let dataSets = messages.compactMap { message -> TrackingDataSet? in
            if let data = try? createJSONDecoder().decode(TrackingData.self, from: message.data) {
                return TrackingDataSet(data: data, message: message)
            }
            return nil
        }

        let requests = Dictionary(grouping: dataSets) { dataSet -> String in
            let data = dataSet.data
            return "\(data.attributions.visitorId)_\(data.attributions.sceneId.identifier)_\(data.attributions.pvId.identifier)"
        }.compactMap { _, dataSets -> TrackRequest? in
            let request = TrackRequest(app: app, dataSets: dataSets, isRetry: false)
            return request
        }.sorted { req1, req2 -> Bool in
            let compare = req1.dataSets[0].data.attributions.date < req2.dataSets[0].data.attributions.date
            return compare
        }
        return requests
    }
}
