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
import KarteUtilities
import ObjectiveC
import UIKit

internal class FCMTokenRegistrar {
    static let shared = FCMTokenRegistrar()

    private var token: String?
    private var subscribe = false

    init() {
    }

    func registerFCMToken() {
        registerFCMToken(fcmToken)
    }

    func registerFCMToken(_ token: String?) {
        guard let token = token else {
            return
        }

        guard isChanged(token: token) else {
            return
        }

        let subscribe = isNotificationAvailable
        Tracker.track(event: Event(.pluginNativeAppIdentify(subscribe: subscribe, fcmToken: token)))

        self.subscribe = subscribe
        self.token = token
    }

    func unregisterFCMToken(visitorId: String? = nil) {
        let tracker = Tracker(visitorId ?? KarteApp.visitorId)
        tracker.track(event: Event(.pluginNativeAppIdentify(subscribe: false, fcmToken: nil)))

        self.subscribe = false
        self.token = nil
    }

    deinit {
    }
}

extension FCMTokenRegistrar {
    private var isNotificationAvailable: Bool {
        let types = UIApplication.shared.currentUserNotificationSettings?.types ?? []
        return types.intersection([.alert, .badge, .sound]).rawValue > 0
    }

    private var fcmToken: String? {
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

    private func isChanged(token: String) -> Bool {
        guard self.token == token else {
            return true
        }
        guard self.subscribe == self.isNotificationAvailable else {
            return true
        }
        return false
    }
}

extension FCMTokenRegistrar: UserModule, NotificationModule {
    var name: String {
        String(describing: type(of: self))
    }

    func renew(visitorId current: String, previous: String) {
        unregisterFCMToken(visitorId: previous)
        registerFCMToken()
    }

    func unsubscribe() {
        unregisterFCMToken()
    }
}
