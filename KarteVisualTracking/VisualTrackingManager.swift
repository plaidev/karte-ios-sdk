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

internal class VisualTrackingManager {
    static let shared = VisualTrackingManager()

    private var receivers: [ActionReceiver] = []
    var tracer: ActionTracer?
    var tracker: ActionTracker?

    init() {
    }

    func configure(app: KarteApp) {
        let tracer = ActionTracer(app: app)
        self.tracer = tracer

        let tracker = ActionTracker(app: app)
        self.tracker = tracker

        register(receiver: tracer)
        register(receiver: tracker)

        UIApplication.krt_vt_swizzleApplicationMethods()
        UIGestureRecognizer.krt_vt_swizzleGestureRecognizerMethods()
        UINavigationController.krt_vt_swizzleNavigationControllerMethods()
        UIViewController.krt_vt_swizzleViewControllerMethods()

        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {[weak self] in
                if let config = self?.tracker?.app.configuration as? ExperimentalConfiguration, config.operationMode == OperationMode.ingest {
                    self?.tracker?.refreshDefinitions()
                }
            }
            if let token = token {
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    func unconfigure(app: KarteApp) {
        tracer?.stopPairing()

        receivers.removeAll()
        tracer = nil
        tracker = nil
    }

    func register(receiver: ActionReceiver) {
        receivers.append(receiver)
    }

    func dispatch(action: Action?) {
        guard let action = action else {
            Logger.warn(tag: .visualTracking, message: "Action is invalid.")
            return
        }
        receivers.forEach { receiver in
            receiver.receive(action: action)
        }
    }

    deinit {
    }
}

extension VisualTrackingManager: ActionModule, DeepLinkModule, TrackModule {
    var name: String {
        String(describing: type(of: self))
    }

    var queue: DispatchQueue? {
        nil
    }

    func receive(response: TrackResponse.Response, request: TrackRequest) {
        tracker?.refreshDefinitions(response: response)
    }

    func reset(sceneId: SceneId) {
    }

    func resetAll() {
    }

    func handle(app: UIApplication, open url: URL) -> Bool {
        guard let account = Account(url: url) else {
            return false
        }
        tracer?.startPairing(account: account)
        return true
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        guard let tracker = tracker else {
            return urlRequest
        }
        return try tracker.intercept(urlRequest: urlRequest)
    }
}
