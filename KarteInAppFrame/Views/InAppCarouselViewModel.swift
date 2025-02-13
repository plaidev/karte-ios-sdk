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

class InAppCarouselViewModel {
    private(set) var model: InAppCarouselModel
    private(set) var imageData: [ParsedImageData] = []
    private(set) var loadingState: InAppFrame.LoadingState = .initialized
    var loadingDelegate: InAppFrame.LoadingDelegate?

    var templateType: InAppCarouselModel.TemplateType {
        model.config.templateType
    }

    init(model: InAppCarouselModel, imageData: [ParsedImageData] = []) {
        self.model = model
        self.imageData = imageData
    }

    func loadContents() async throws {
        do {
            self.loadingState = .loading
            await self.loadingDelegate?.didChangeLoadingState(to: .loading)

            let rawImageData = try await ImageLoader().fetchImagesWithLinkUrl(of: model)
            for data in rawImageData {
                self.imageData.append(data)
            }
            self.loadingState = .completed
            await self.loadingDelegate?.didChangeLoadingState(to: .completed)
        } catch {
            Logger.warn(tag: .inAppFrame, message: "Failed to load carousel contents. error: \(error)")
            self.loadingState = .failed
            await self.loadingDelegate?.didChangeLoadingState(to: .failed)
            throw error
        }
    }

    func cancellLoadingState() async {
        self.loadingState = .failed
        await self.loadingDelegate?.didChangeLoadingState(to: .failed)
    }

    func getImageWidth() -> CGFloat {
        floor(CGFloat(getImageHeidht() * getImageRatio()))
    }

    func getImageHeidht() -> CGFloat {
        let height: CGFloat
        switch model.config.templateType {
        case .carouselWithoutMargin:
            guard getImageRatio() > 0 else {
                Logger.warn(tag: .inAppFrame, message: "Failed to compute image ratio, getImageRatio returns 0")
                return 0
            }
            height = UIScreen.main.bounds.width / getImageRatio()
        case .carouselWithMargin, .carouselWithoutPaging:
            height = CGFloat(model.config.bannerHeight ?? 0)
        case .simpleBanner:
             guard getImageRatio() > 0 else {
                Logger.warn(tag: .inAppFrame, message: "Failed to compute image ratio, getImageRatio returns 0")
                return 0
            }
            let paddingStart = CGFloat(model.config.paddingStart ?? 0)
            let paddingEnd = CGFloat(model.config.paddingEnd ?? 0)
            height = (UIScreen.main.bounds.width - (paddingStart + paddingEnd)) / getImageRatio()
        }
        return height
    }

    func getImageRatio() -> CGFloat {
        Double(model.config.ratio) / 100.0
    }

    func getItemSpacing() -> CGFloat {
        CGFloat(model.config.spacing ?? 0)
    }

    func getTopMargin() -> CGFloat {
        CGFloat(model.config.paddingTop ?? 0)
    }

    func getBottomMargin() -> CGFloat {
        CGFloat(model.config.paddingBottom ?? 0)
    }

    func getStartMargin() -> CGFloat {
        CGFloat(model.config.paddingStart ?? 0)
    }

    func getEndMargin() -> CGFloat {
        CGFloat(model.config.paddingEnd ?? 0)
    }

    func getScrollBehaviour() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
        let scrollType: UICollectionLayoutSectionOrthogonalScrollingBehavior
        switch model.config.templateType {
        case .carouselWithoutMargin, .carouselWithMargin:
            scrollType = .groupPagingCentered
        case .carouselWithoutPaging:
            scrollType = .continuous
        case .simpleBanner:
            scrollType = .none
        }
        return scrollType
    }

    func getAutoplaySpeed() -> Double {
        Double(model.config.autoplaySpeed ?? 0)
    }
}
