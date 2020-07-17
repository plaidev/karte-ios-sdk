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

internal class NotificationCommandHandler {
    static let shared = NotificationCommandHandler()

    init() {
    }

    deinit {
    }
}

extension NotificationCommandHandler: DeepLinkModule {
    public var name: String {
        String(describing: type(of: self))
    }

    public func handle(app: UIApplication, open url: URL) -> Bool {
        let cmd = RegisterPushCommand()
        return cmd.run(url: url)
    }
}
