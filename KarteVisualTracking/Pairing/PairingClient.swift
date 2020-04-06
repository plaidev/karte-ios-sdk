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
import KarteUtilities

internal class PairingClient {
    var app: KarteApp
    var account: Account
    var timer: SafeTimer
    var isPairing = false

    private var bgTaskSupporter = BackgroundTaskSupporter()

    init(app: KarteApp, account: Account) {
        self.app = app
        self.account = account

        let queue = DispatchQueue(
            label: "io.karte.vt.pairing",
            qos: DispatchQoS(qosClass: .utility, relativePriority: 1_000)
        )

        let timer = SafeTimer(timeInterval: .seconds(5), queue: queue)
        self.timer = timer
    }

    func startPairing() {
        guard let request = PairingRequest(app: app, account: account) else {
            return
        }
        Session.send(request, callbackQueue: .sessionQueue) { [weak self] result in
            switch result {
            case .success:
                Logger.info(tag: .visualTracking, message: "Pairing was successful.")
                self?.startPolling()

            case .failure(let error):
                Logger.error(tag: .visualTracking, message: "Failed to pairing request. \(error.localizedDescription)")
            }
        }
    }

    func stopPairing() {
        if isPairing {
            stopPolling()
        }
    }

    private func startPolling() {
        if isPairing {
            return
        }

        isPairing = true

        bgTaskSupporter.observeLifecycle()

        timer.eventHandler = { [weak self] in
            self?.heartbeat()
        }
        timer.resume()
    }

    private func stopPolling() {
        guard isPairing else {
            return
        }

        timer.suspend()
        isPairing = false

        bgTaskSupporter.unobserveLifecycle()
    }

    private func heartbeat() {
        let request = PairingHeartbeatRequest(app: app, account: account)
        Session.send(request, callbackQueue: .sessionQueue) { [weak self] result in
            switch result {
            case .success:
                Logger.verbose(tag: .visualTracking, message: "Heartbeat was successful.")

            case .failure(let error):
                Logger.error(tag: .visualTracking, message: "Failed to heartbeat request. \(error.localizedDescription)")
                self?.stopPolling()
            }
        }
    }

    deinit {
    }
}
