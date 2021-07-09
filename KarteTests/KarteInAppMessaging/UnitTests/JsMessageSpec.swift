//
//  Copyright 2021 PLAID, Inc.
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

import WebKit
import Quick
import Nimble
@testable import KarteInAppMessaging

class TestMessage: WKScriptMessage {
    let messageBody: Any
    let mssageFrameInfo: WKFrameInfo
    let messageName: String
    let messageWebView: WKWebView
    
    internal init(messageBody: Any, mssageFrameInfo: WKFrameInfo, messageName: String, messageWebView: WKWebView) {
        self.messageBody = messageBody
        self.mssageFrameInfo = mssageFrameInfo
        self.messageName = messageName
        self.messageWebView = messageWebView
    }
    
    override var body: Any {
        self.messageBody
    }
    
    override var frameInfo: WKFrameInfo {
        self.mssageFrameInfo
    }
    
    override var name: String {
        self.messageName
    }
    
    override var webView: WKWebView? {
        self.messageWebView
    }
}

class JsMessageSpec: QuickSpec {
    
    override func spec() {
        describe("its init") {
            let testWebview = WKWebView()
            let testFrameInfo = WKFrameInfo()
            
            it("is no error") {
                let testBody = [
                    "event_name": "test",
                    "values": ["name": "test name"]
                ] as [String : Any]
                let testMessage = TestMessage(messageBody: testBody,
                                              mssageFrameInfo: testFrameInfo,
                                              messageName: JsMessageName.event.rawValue,
                                              messageWebView: testWebview)
                expect({
                    try JsMessage.init(scriptMessage: testMessage)
                }).notTo(throwError())
            }
            
            it("is throw invalidBody") {
                let testBody = ["test_key": NSDate.now]
                let testMessage = TestMessage(messageBody: testBody,
                                              mssageFrameInfo: testFrameInfo,
                                              messageName: JsMessageName.event.rawValue,
                                              messageWebView: testWebview)
                expect({
                    try JsMessage.init(scriptMessage: testMessage)
                }).to(throwError(JsMessageError.invalidBody))
            }
            
            it("is throw invalidName") {
                let testBody = ["test_key": "test_value"]
                let testMessage = TestMessage(messageBody: testBody,
                                              mssageFrameInfo: testFrameInfo,
                                              messageName: "test name",
                                              messageWebView: testWebview)
                expect({
                    try JsMessage.init(scriptMessage: testMessage)
                }).to(throwError(JsMessageError.invalidName))
            }
        }
    }
}
