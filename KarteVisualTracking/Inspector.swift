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

import KarteUtilities
import UIKit

internal enum Inspector {
    static func inspectText(with element: Any?) -> String? {
        guard let element = element else {
            return nil
        }

        let object = element as AnyObject
        if let title: String = AnyObjectHelper.propertyValue(from: object, propertyName: "title") {
            return title
        } else if let text: String = AnyObjectHelper.propertyValue(from: object, propertyName: "text") {
            return text
        } else if let subviews: [UIView] = AnyObjectHelper.propertyValue(from: object, propertyName: "subviews") {
            for subview in subviews {
                if let text = inspectText(with: subview) {
                    return text
                }
            }
        }

        return nil
    }

    /// View階層のパス情報でwindowのsubViewを探索して見つかったViewを返す
    static func inspectView(with viewPathIndices: [Int], inWindow window: UIWindow?) -> UIView? {
        guard var target: UIView = window, viewPathIndices.count > 0 else {
            return nil
        }

        for index in viewPathIndices {
            guard target.subviews.indices.contains(index) else {
                return nil
            }
            let next = target.subviews[index]
            target = next
        }

        return target
    }

    static func takeSnapshot(with view: UIView?) -> UIImage? {
        guard let view = view else {
            return nil
        }

        func draw(with view: UIView) -> UIImage? {
            defer {
                UIGraphicsEndImageContext()
            }

            UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
            return UIGraphicsGetImageFromCurrentImageContext()
        }

        func cropping(originView: UIView, renderingView: UIView, image: UIImage) -> UIImage? {
            let scale = image.scale

            var rect = originView.convert(originView.bounds, to: renderingView)
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale

            let croppedImage = image.cgImage?.cropping(to: rect).flatMap {
                UIImage(cgImage: $0, scale: scale, orientation: image.imageOrientation)
            }
            return croppedImage
        }

        let renderingView = UIResponder.krt_vt_retrieveViewController(for: view)?.view ?? view
        let image = draw(with: renderingView).flatMap {
            cropping(originView: view, renderingView: renderingView, image: $0)
        }

        return image
    }
}
