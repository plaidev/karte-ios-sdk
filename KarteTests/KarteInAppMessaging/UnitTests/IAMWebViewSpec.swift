//
//  Copyright 2026 PLAID, Inc.
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
import XCTest
import WebKit
@testable import KarteCore
@testable import KarteInAppMessaging

fileprivate class SpyIAMWebView: IAMWebView {
    var loadCallCount = 0

    override func load(_ request: URLRequest) -> WKNavigation? {
        loadCallCount += 1
        return nil
    }
}

fileprivate class MockIAMWebViewDelegate: IAMWebViewDelegate {
    func showInAppMessagingWebView(_ webView: IAMWebView) -> Bool { true }
    func hideInAppMessagingWebView(_ webView: IAMWebView) -> Bool { true }
    func inAppMessagingWebView(_ webView: IAMWebView, shouldOpenURL url: URL) -> Bool { true }
}

@MainActor
class IAMWebViewSpec: XCTestCase {
    // swiftlint:disable:next force_unwrapping
    let overlayURL = URL(string: "https://cf-native.karte.io/v0/native/overlay")!
    // swiftlint:disable:next force_unwrapping
    let dummyURL = URL(string: "https://example.com")!
    let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
    let emptyViewValues: [String: JSONValue] = [:]

    fileprivate var webView: SpyIAMWebView!
    fileprivate var mockDelegate: MockIAMWebViewDelegate!

    override func setUp() {
        super.setUp()
        mockDelegate = MockIAMWebViewDelegate()
        webView = SpyIAMWebView(
            sceneId: SceneId("DEFAULT"),
            configuration: WKWebViewConfiguration(),
            url: overlayURL
        )
        webView.delegate = mockDelegate
    }

    fileprivate func makeNonOverlayWebView() -> SpyIAMWebView {
        let view = SpyIAMWebView(
            sceneId: SceneId("DEFAULT"),
            configuration: WKWebViewConfiguration(),
            url: dummyURL
        )
        view.delegate = mockDelegate
        return view
    }

    // MARK: - didFailProvisionalNavigation

    func test_didFailProvisionalNavigation_overlayURL_handleResponse_retries() {
        webView.handle(response: EMPTY_RESPONSE)
        let countAfterInitial = webView.loadCallCount

        webView.webView(webView, didFailProvisionalNavigation: nil, withError: networkError)

        webView.handle(response: EMPTY_RESPONSE)
        XCTAssertEqual(webView.loadCallCount, countAfterInitial + 1)
    }

    func test_didFailProvisionalNavigation_overlayURL_handleView_doesNotRetry() {
        webView.handle(response: EMPTY_RESPONSE)
        let countAfterInitial = webView.loadCallCount

        webView.webView(webView, didFailProvisionalNavigation: nil, withError: networkError)

        webView.handleView(values: emptyViewValues)
        XCTAssertEqual(webView.loadCallCount, countAfterInitial)
    }

    func test_didFailProvisionalNavigation_nonOverlayURL_handleResponse_doesNotRetry() {
        let nonOverlayWebView = makeNonOverlayWebView()
        nonOverlayWebView.handle(response: EMPTY_RESPONSE)
        let countAfterInitial = nonOverlayWebView.loadCallCount

        nonOverlayWebView.webView(nonOverlayWebView, didFailProvisionalNavigation: nil, withError: networkError)

        nonOverlayWebView.handle(response: EMPTY_RESPONSE)
        XCTAssertEqual(nonOverlayWebView.loadCallCount, countAfterInitial)
    }

    // MARK: - didFail

    func test_didFail_overlayURL_handleResponse_retries() {
        webView.handle(response: EMPTY_RESPONSE)
        let countAfterInitial = webView.loadCallCount

        webView.webView(webView, didFail: nil, withError: networkError)

        webView.handle(response: EMPTY_RESPONSE)
        XCTAssertEqual(webView.loadCallCount, countAfterInitial + 1)
    }

    func test_didFail_nonOverlayURL_handleResponse_doesNotRetry() {
        let nonOverlayWebView = makeNonOverlayWebView()
        nonOverlayWebView.handle(response: EMPTY_RESPONSE)
        let countAfterInitial = nonOverlayWebView.loadCallCount

        nonOverlayWebView.webView(nonOverlayWebView, didFail: nil, withError: networkError)

        nonOverlayWebView.handle(response: EMPTY_RESPONSE)
        XCTAssertEqual(nonOverlayWebView.loadCallCount, countAfterInitial)
    }
}
