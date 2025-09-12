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

import KarteCore
import UIKit
import UserNotifications

internal struct RegisterPushCommand: Command {
    func validate(_ url: URL) -> Bool {
        url.host == "register-push"
    }

    func execute() {
        requestAuth()
    }
}

extension RegisterPushCommand {
    private func requestAuth() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else {
                return
            }

            current.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    Logger.error(tag: .notification, message: "Failed to request authorization: \(error)")
                }

                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
}
