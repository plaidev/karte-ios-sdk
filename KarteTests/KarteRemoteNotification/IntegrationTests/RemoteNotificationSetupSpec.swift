//
//  Copyright 2021 PLAID, Inc.
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

import Quick
import Nimble
@testable import KarteCore
@testable import KarteRemoteNotification

class RemoteNotificationSetupSpec: QuickSpec {
    
    override func spec() {
        
        describe("a remote notification module") {
            beforeEach {
                RemoteNotification.isEnabledAutoMeasurement = true
            }
            context("its setup with default configuration") {
                beforeEach {
                    if let configuration = Configuration.default {
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    }
                }
                
                it("RemoteNotificationProxy is enabled") {
                    expect(RemoteNotificationProxy.shared.isEnabled).to(beTrue())
                }
            }
                
            context("its setup with default library configration") {
                beforeEach {
                    if let configuration = Configuration.default {
                        configuration.libraryConfigurations = [RemoteNotificationConfiguration()]
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    }
                }
                
                it("RemoteNotificationProxy is enabled") {
                    expect(RemoteNotificationProxy.shared.isEnabled).to(beTrue())
                }
            }
            
            context("its setup with custom library configration") {
                beforeEach {
                    if let configuration = Configuration.default {
                        let remoteNotificationConfiguration = RemoteNotificationConfiguration()
                        remoteNotificationConfiguration.isEnabledAutoMeasurement = false
                        configuration.libraryConfigurations = [remoteNotificationConfiguration]
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    }
                }
                
                it("RemoteNotificationProxy is disabled") {
                    expect(RemoteNotificationProxy.shared.isEnabled).to(beFalse())
                }
            }
            
            context("its setup with deprecated static config") {
                beforeEach {
                    RemoteNotification.isEnabledAutoMeasurement = false
                    KarteApp.setup(appKey: APP_KEY)
                }
                
                it("RemoteNotificationProxy is disabled") {
                    expect(RemoteNotificationProxy.shared.isEnabled).to(beFalse())
                }
            }
        }
    }
}
