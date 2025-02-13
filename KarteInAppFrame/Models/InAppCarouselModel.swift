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

struct InAppCarouselModel: InAppFrameModel, Decodable {
    let data: [Content]
    let config: Config

    struct Content: Decodable {
        let index: Int
        let imageUrl: URL
        let linkUrl: String?
    }

    struct Config: Decodable {
        let templateType: TemplateType
        let autoplaySpeed: Double?
        let radius: Int
        let ratio: Int
        let bannerHeight: Int?
        let spacing: Int?
        let paddingStart: Int?
        let paddingEnd: Int?
        let paddingTop: Int?
        let paddingBottom: Int?
    }

    enum TemplateType: String, Decodable {
        case carouselWithMargin
        case carouselWithoutMargin
        case carouselWithoutPaging
        case simpleBanner
    }
}
