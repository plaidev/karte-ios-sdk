//
//  Copyright 2024 PLAID, Inc.
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
import KarteCore

@available(iOS 14.0, *)
struct InAppFrameFactory {
    private init() {}

    static func create(for arg: InAppFrameArg,
                       loadingDelegate: InAppFrame.LoadingDelegate? = nil,
                       itemTapListener: InAppFrame.ItemTapListener? = nil
    ) async -> UIView? {
        switch arg.componentType {
        case .iafCarousel:
            switch arg.version {
            case .v1:
                guard let model = arg.content as? InAppCarouselModel else {
                    Logger.warn(tag: .inAppFrame, message: "Invalid data format: \(arg)")
                    return nil
                }
                return await KRTInAppCarousel(
                    for: arg.keyName, model: model, loadingDelegate: loadingDelegate, itemTapListener: itemTapListener
                )
            }
        }
    }
}
