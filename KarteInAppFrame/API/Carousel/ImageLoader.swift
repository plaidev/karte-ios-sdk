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

struct ImageLoader {
    func fetchImagesWithLinkUrl(of model: InAppCarouselModel) async throws -> [ParsedImageData] {
        // NOTE: Define indexed map for sorting images fetched by parallel requests
        // [index: (imageUrl, image, linkUrl)]
        var temp = [Int: ParsedImageData]()
        try await withThrowingTaskGroup(of: (Int, URL, Data, String?).self) { group in
            for content in model.data {
                group.addTask {
                    let data = try await self.loadData(from: content.imageUrl)
                    return (content.index, content.imageUrl, data, content.linkUrl)
                }
            }
            for try await (index, imageUrl, data, linkUrl) in group {
                if let img = UIImage(data: data) {
                    temp[index] = .init(index: index, imageUrl: imageUrl, image: img, linkUrl: URL(string: linkUrl ?? ""))
                }
            }
        }
        // Convert indexed map to sorted array by its index
        let images: [ParsedImageData] = temp.sorted(by: { $0.key < $1.key }).reduce(into: [ParsedImageData]()) { acc, elem in
            acc.append(elem.value)
        }
        return images
    }

    private func loadData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

struct ParsedImageData: Hashable {
    let index: Int
    let imageUrl: URL
    let image: UIImage
    let linkUrl: URL?
}
