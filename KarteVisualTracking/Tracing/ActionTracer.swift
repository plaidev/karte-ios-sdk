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
import UIKit

internal class ActionTracer {
    internal var pairingClient: PairingClient?
    private var queue: DispatchQueue
    private var app: KarteApp

    init(app: KarteApp) {
        self.app = app
        self.queue = DispatchQueue(
            label: "io.karte.vt.tracer",
            qos: DispatchQoS(qosClass: .utility, relativePriority: 500)
        )
    }

    func startPairing(account: Account) {
        let pairingClinet = PairingClient(app: app, account: account)
        pairingClinet.startPairing()

        self.pairingClient = pairingClinet
    }

    func stopPairing() {
        guard let pairingClient = self.pairingClient else {
            return
        }
        pairingClient.stopPairing()
    }

    deinit {
    }
}

extension ActionTracer {
    internal func trace(account: Account, action: ActionProtocol, image: UIImage?) {
        let data = image?.jpegData(compressionQuality: 0.7)
        guard let request = TraceRequest(app: app, account: account, action: action, image: data) else {
            return
        }
        Session.send(request, callbackQueue: .sessionQueue) { result in
            switch result {
            case .success:
                Logger.verbose(tag: .visualTracking, message: "Trace was successful.")

            case .failure(let error):
                Logger.error(tag: .visualTracking, message: "Failed to trace request. \(error.localizedDescription)")
            }
        }
    }
}

extension ActionTracer: ActionReceiver {
    func receive(action: ActionProtocol) {
        guard let pairingClient = pairingClient, pairingClient.isPaired else {
            Logger.verbose(tag: .visualTracking, message: "Not paired.")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            let image = action.image()
            self.queue.async { [weak self] in
                self?.trace(account: pairingClient.account, action: action, image: image)
            }
        }
    }
}
