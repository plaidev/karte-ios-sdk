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

internal struct OpacityDetector {
    private var cache = Cache()

    mutating func detectAtPoint(_ point: CGPoint, view: UIView, event: UIEvent?) -> Bool {
        // Determine if the place you tap is opaque.
        // If it takes around 100 milliseconds to make a decision, it will affect operations such as scrolling and pinching in and out, so the process must be completed within about 16 milliseconds.
        func detect(_ point: CGPoint, view: UIView, event: UIEvent?) -> Bool {
            // Check if the background color is transparent.
            var leafs = [UIView]()
            let isOpacity = detectAndCollectLeafViewAtPoint(point, view: view, event: event) { leaf in
                leafs.append(leaf)
            }
            if isOpacity {
                return true
            }

            // Render the end view and check if it is opaque.
            for leaf in leafs {
                let leafPoint = leaf.convert(point, from: view)
                let isOpacity = detectAtPoint(leafPoint, view: leaf)
                if isOpacity {
                    return true
                }
            }

            // Render the root view and check if it is opaque.
            if let cls = ClassLoader.compoingViewClass, var root = leafs.first {
                while root.isKind(of: cls) {
                    if let superview = root.superview {
                        root = superview
                    } else {
                        break
                    }
                }

                let rootPoint = root.convert(point, from: view)
                let isOpacity = detectAtPoint(rootPoint, view: root)
                if isOpacity {
                    return true
                }
            }

            return detectAtPoint(point, view: view)
        }

        let isOpacity: Bool
        if cache.isExpired(event: event) {
            isOpacity = detect(point, view: view, event: event)

            // If multiple events occur in a short period of time, use the first cached result.
            if let event = event {
                self.cache = Cache(event: event, isOpacity: isOpacity)
            }
        } else {
            isOpacity = cache.isOpacity
        }

        return isOpacity
    }
}

extension OpacityDetector {
    private func detectAndCollectLeafViewAtPoint(_ point: CGPoint, view: UIView, event: UIEvent?, collector: ((UIView) -> Void)? = nil) -> Bool {
        if view.point(inside: point, with: event) {
            // Check if the background color is opaque.
            if let backgroundColor = view.backgroundColor {
                var alpha: CGFloat = 0
                backgroundColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)

                if alpha > 0 {
                    return true
                }
            }

            // Check if it is a end view.
            if view.subviews.isEmpty {
                collector?(view)
            }
        }

        for subview in view.subviews {
            let subviewPoint = subview.convert(point, from: view)
            let isOpacity = detectAndCollectLeafViewAtPoint(
                subviewPoint,
                view: subview,
                event: event,
                collector: collector
            )
            if isOpacity {
                return true
            }
        }

        return false
    }

    private func detectAtPoint(_ point: CGPoint, view: UIView) -> Bool {
        var bitmap = [UInt8](repeating: 0, count: 4)
        let ctx = CGContext(
            data: &bitmap,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )

        guard let context = ctx else {
            return false
        }

        context.translateBy(x: -point.x, y: -point.y)

        UIGraphicsPushContext(context)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        UIGraphicsPopContext()

        return bitmap[0] > 0
    }
}

internal extension OpacityDetector {
    struct Cache {
        var lastEventAt: UInt
        var isOpacity: Bool

        init() {
            self.lastEventAt = 0
            self.isOpacity = false
        }

        init(event: UIEvent, isOpacity: Bool) {
            self.lastEventAt = UInt(event.timestamp * 1_000)
            self.isOpacity = isOpacity
        }

        func isExpired(event: UIEvent?) -> Bool {
            guard let event = event else {
                return true
            }
            guard lastEventAt > 0 else {
                return true
            }
            return lastEventAt != UInt(event.timestamp * 1_000)
        }
    }
}
