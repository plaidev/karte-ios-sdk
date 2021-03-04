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

internal class FCMTokenRegistrar {
    static let shared = FCMTokenRegistrar(DefaultNotificationSettingsProvider())

    private var notificationSettingsProvider: NotificationSettingsProvider
    private var token: String?
    private var subscribe = false

    init(_ notificationSettingsProvider: NotificationSettingsProvider) {
        self.notificationSettingsProvider = notificationSettingsProvider

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    func registerFCMToken() {
        registerFCMToken(notificationSettingsProvider.fcmToken)
    }

    func registerFCMToken(_ token: String?) {
        guard let token = token else {
            return
        }

        notificationSettingsProvider.checkAvailability { [weak self] subscribe in
            guard let self = self, self.isChanged(token: token, subscribe: subscribe) else {
                return
            }

            Tracker.track(event: Event(.pluginNativeAppIdentify(subscribe: subscribe, fcmToken: token)))

            self.subscribe = subscribe
            self.token = token
        }
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
    private func isChanged(token: String, subscribe: Bool) -> Bool {
        guard self.token == token else {
            return true
        }
        guard self.subscribe == subscribe else {
            return true
        }
        return false
    }

    @objc
    private func didBecomeActiveNotification(_ notification: Notification) {
        registerFCMToken()
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
