//
//  Copyright 2025 PLAID, Inc.
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

import SwiftUI

public struct IAFCarousel: View {
    private let variableKey: String

    public init(variableKey: String) {
        self.variableKey = variableKey
    }

    public var body: some View {
        VStack {
            WrappedCarousel(variableKey: variableKey)
        }
    }
}

private struct WrappedCarousel: UIViewRepresentable {
    let variableKey: String

    func makeUIView(context: Context) -> UIStackView {
        return UIStackView()
    }

    func updateUIView(_ uiView: UIStackView, context: Context) {
        uiView.arrangedSubviews.forEach { v in
            uiView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        Task {
            guard let iaf = await InAppFrame.loadContent(for: variableKey) else {
                return
            }
            uiView.addArrangedSubview(iaf)
        }
    }
}

#Preview {
    IAFCarousel(variableKey: "carousel_with_margin")
}
