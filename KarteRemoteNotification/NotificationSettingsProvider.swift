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

import KarteUtilities
import UIKit
import UserNotifications

internal protocol NotificationSettingsProvider {
    var fcmToken: String? { get }
    func checkAvailability(completionHandler: @escaping (Bool) -> Void)
}

extension NotificationSettingsProvider {
    var fcmToken: String? {
        guard let messagingClass = NSClassFromString("FIRMessaging") else {
            return nil
        }
        guard let messaging = AnyObjectHelper.propertyValue(from: messagingClass, propertyName: "messaging", cls: messagingClass) else {
            return nil
        }
        guard let token = AnyObjectHelper.propertyValue(from: messaging, propertyName: "FCMToken", cls: NSString.self) as? String else {
            return nil
        }
        return token
    }

    func checkAvailability(completionHandler: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAvailable = self.checkAvailability(settings: settings)
            completionHandler(isAvailable)
        }
    }

    private func checkAvailability(settings: UNNotificationSettings) -> Bool {
        switch settings.authorizationStatus {
        case .authorized:
            break

        case .denied, .notDetermined:
            return false

        case .provisional:
            // When using provisional, only the notificationCenterSetting is enabled.
            // When you change the notification settings in the Settings app, it is automatically changed to authorized.
            return true

        case .ephemeral:
            return true

        @unknown default:
            return false
        }

        let isAvailable = [
            settings.alertSetting,
            settings.notificationCenterSetting,
            settings.lockScreenSetting,
            settings.soundSetting,
            settings.badgeSetting
        ].contains(.enabled)

        return isAvailable
    }
}

internal struct DefaultNotificationSettingsProvider: NotificationSettingsProvider {
}
