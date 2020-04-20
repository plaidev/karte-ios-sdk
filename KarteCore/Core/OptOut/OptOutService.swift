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

internal class OptOutService {
    @Injected
    var settings: OptOutSettings

    var configuration: Configuration

    var isOptOut: Bool {
        if isOptOutTemporarily {
            return true
        }
        if settings.hasSettings {
            return settings.isEnabled
        }
        return configuration.isOptOut
    }

    private var isOptOutTemporarily = false

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func optIn() {
        settings.isEnabled = false
    }

    func optOut() {
        if isOptOut {
            return
        }

        settings.isEnabled = true

        KarteApp.shared.modules.forEach { module in
            if case let .action(module) = module {
                module.resetAll()
            }
            if case let .notification(module) = module {
                module.unsubscribe()
            }
        }
    }

    func optOutTemporarily() {
        isOptOutTemporarily = true
    }

    deinit {
    }
}

extension Resolver {
    static func registerOptOutService() {
        register { OptOutSettings() }
    }
}
