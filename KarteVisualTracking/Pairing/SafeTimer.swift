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

internal class SafeTimer {
    private enum State {
        case suspended
        case resumed
    }

    var eventHandler: (() -> Void)?

    private let timeInterval: DispatchTimeInterval
    private let queue: DispatchQueue
    private var state: State = .suspended

    private lazy var timer: DispatchSourceTimer = {
        let tmr = DispatchSource.makeTimerSource(flags: [], queue: queue)
        tmr.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        tmr.setEventHandler { [weak self] in
            self?.eventHandler?()
        }
        return tmr
    }()

    init(timeInterval: DispatchTimeInterval, queue: DispatchQueue) {
        self.timeInterval = timeInterval
        self.queue = queue
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
}
