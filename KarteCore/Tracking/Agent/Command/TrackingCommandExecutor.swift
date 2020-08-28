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

internal protocol TrackingCommandExecutorDelegate: AnyObject {
    func trackingCommandExecutor(_ executor: TrackingCommandExecutor, didCompleteCommand command: TrackingCommand)
    func trackingCommandExecutor(_ executor: TrackingCommandExecutor, didFailCommand command: TrackingCommand)
    func trackingCommandExecutorDidExecuteCommands(_ executor: TrackingCommandExecutor)
}

internal protocol TrackingCommandExecutor {
    var delegate: TrackingCommandExecutorDelegate? { get set }
    var repository: TrackingCommandRepository { get }

    func addCommand(_ command: TrackingCommand)
}
