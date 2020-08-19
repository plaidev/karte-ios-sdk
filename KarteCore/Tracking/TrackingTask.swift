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

/// イベントトラッキングのリクエスト完了をハンドルするためのブロックの宣言です。
public typealias TrackCompletion = (_ successful: Bool) -> Void

@objc(KRTTrackingTask)
public class TrackingTask: NSObject {
    @objc public var completion: TrackCompletion?

    var event: Event
    var visitorId: String
    weak var view: UIView?
    var date = Date()

    init(event: Event, visitorId: String = KarteApp.visitorId, view: UIView? = nil) {
        self.event = event
        self.visitorId = visitorId
        self.view = view
    }

    func resolve() {
        DispatchQueue.main.async {
            self.completion?(true)
        }
    }

    func reject() {
        DispatchQueue.main.async {
            self.completion?(false)
        }
    }

    deinit {
    }
}
