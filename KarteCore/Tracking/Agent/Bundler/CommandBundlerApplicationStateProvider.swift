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

internal protocol CommandBundlerApplicationStateProviderDelegate: AnyObject {
    func commandBundlerApplicationStateProvider(_ provider: CommandBundlerApplicationStateProvider, didChangeApplicationState applicationState: UIApplication.State)
}

internal protocol CommandBundlerApplicationStateProvider {
    var delegate: CommandBundlerApplicationStateProviderDelegate? { get set }
}

internal class DefaultCommandBundlerApplicationStateProvider: CommandBundlerApplicationStateProvider {
    weak var delegate: CommandBundlerApplicationStateProviderDelegate?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observe(notification:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observe(notification:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observe(notification:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observe(notification:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }

    deinit {
    }
}

private extension DefaultCommandBundlerApplicationStateProvider {
    @objc
    func observe(notification: Notification) {
        delegate?.commandBundlerApplicationStateProvider(self, didChangeApplicationState: UIApplication.shared.applicationState)
    }
}
