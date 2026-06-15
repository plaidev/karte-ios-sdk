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
import XCTest
@testable import KarteInAppMessaging

class TestMessage: WKScriptMessage {
    let messageBody: Any
    let messageName: String

    internal init(messageBody: Any, messageName: String) {
        self.messageBody = messageBody
        self.messageName = messageName
    }

    override var body: Any {
        self.messageBody
    }

    override var name: String {
        self.messageName
    }

    override var webView: WKWebView? {
        nil
    }
}

class JsMessageSpec: XCTestCase {
    func testInitWithValidBodyDoesNotThrow() {
        let testBody = [
            "event_name": "test",
            "values": ["name": "test name"]
        ] as [String: Any]
        let testMessage = TestMessage(messageBody: testBody,
                                      messageName: JsMessageName.event.rawValue)
        XCTAssertNoThrow(try JsMessage(scriptMessage: testMessage), "valid body should not throw")
    }

    func testInitWithInvalidBodyThrowsInvalidBody() {
        let testBody = ["test_key": NSDate.now]
        let testMessage = TestMessage(messageBody: testBody,
                                      messageName: JsMessageName.event.rawValue)
        XCTAssertThrowsError(try JsMessage(scriptMessage: testMessage), "invalid body should throw") { error in
            XCTAssertEqual(error as? JsMessageError, JsMessageError.invalidBody, "should throw invalidBody")
        }
    }

    func testInitWithInvalidNameThrowsInvalidName() {
        let testBody = ["test_key": "test_value"]
        let testMessage = TestMessage(messageBody: testBody,
                                      messageName: "test name")
        XCTAssertThrowsError(try JsMessage(scriptMessage: testMessage), "invalid name should throw") { error in
            XCTAssertEqual(error as? JsMessageError, JsMessageError.invalidName, "should throw invalidName")
        }
    }
}
