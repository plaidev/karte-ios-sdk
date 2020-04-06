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

import UIKit
import KarteUtilities
@testable import KarteCore

extension Resolver {
    static let mock = Resolver(parent: .main)
    static let submock = Resolver(parent: .mock)
    
    static func registerMockServices() {
        Resolver.main.registerServices()
        
        let resolver = Resolver.mock
        
        // AppInfo
        resolver.register(String.self, name: "app_info.version_name") {
            "1.0.0"
        }
        resolver.register(String.self, name: "app_info.version_code") {
            "1"
        }
        resolver.register(String.self, name: "app_info.karte_sdk_version") {
            "1.0.0"
        }
        resolver.register([String: String].self, name: "app_info.module_info") {
            [
                "core": "2.0.0",
                "in_app_messaging": "2.0.0"
            ]
        }
        resolver.register(SystemInfo.self, name: "app_info.system_info") {
            SystemInfo()
        }
        
        // SystemInfo
        resolver.register(String.self, name: "system_info.os") {
            "iOS"
        }
        resolver.register(String.self, name: "system_info.os_version") {
            "13.0"
        }
        resolver.register(String.self, name: "system_info.device") {
            "iPhone"
        }
        resolver.register(String.self, name: "system_info.model") {
            "iPhone10,3"
        }
        resolver.register(String.self, name: "system_info.bundle_id") {
            "io.karte"
        }
        resolver.register(String.self, name: "system_info.idfv") {
            "dummy_idfv"
        }
        resolver.register(String.self, name: "system_info.idfa") {
            guard let idfaDelegate = KarteApp.shared.configuration.idfaDelegate else {
                return nil
            }
            guard idfaDelegate.isAdvertisingTrackingEnabled else {
                return nil
            }
            return idfaDelegate.advertisingIdentifierString
        }
        resolver.register(String.self, name: "system_info.language") {
            "ja-JP"
        }
        resolver.register(Screen.self, name: "system_info.screen") {
            Screen()
        }

        // Screen
        resolver.register(CGFloat.self, name: "screen.width") {
            CGFloat(375)
        }
        resolver.register(CGFloat.self, name: "screen.height") {
            CGFloat(812)
        }

        //
        resolver.register(name: "visitor_id_service.generator") {
            VisitorIdGeneratorMock() as IdGenerator
        }
        resolver.register(name: "version_service.current_version_retriever") {
            VersionRetrieverMock() as VersionRetriever
        }
        resolver.register(name: "pv_service.pv_id_bucket") { () -> PvIdBucket? in
            var bucket = PvIdBucket()
            let pvId = PvId("dummy_pv_id")
            bucket.set(pvId, forKey: SceneId(view: nil))
            return bucket
        }
        resolver.register(name: "pv_service.original_pv_id_bucket") { () -> PvIdBucket? in
            var bucket = PvIdBucket()
            let pvId = PvId("dummy_original_pv_id")
            bucket.set(pvId, forKey: SceneId(view: nil))
            return bucket
        }
        resolver.register { PubSubApplicationMock() as PubSubApplication }
        
        Resolver.root = Resolver.mock
    }
}
