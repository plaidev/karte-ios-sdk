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

import Quick
import Nimble
import Mockingjay
import KarteUtilities
@testable import KarteCore

class TrackDelegate: NSObject, TrackerDelegate {
    
    func intercept(_ event: Event) -> Event {
        var event = event
        event.merge(["foo": "bar"])
        return event
    }
}

class TrackDelegateSpec: QuickSpec {
    
    override func spec() {
        var delegate: TrackDelegate!
        var builder: Builder!
        
        beforeSuite {
            delegate = TrackDelegate()
            builder = { (request) -> Response in
                let response = TrackResponse(success: 1, status: 200, response: .emptyResponse, error: nil)
                let data = try! createJSONEncoder().encode(response)
                return jsonData(data)(request)
            }
        }
        
        afterSuite {
            Tracker.setDelegate(nil)
        }
        
        describe("a tracker") {
            describe("its delegate") {
                var event: Event!
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: builder, eventName: .nativeAppOpen) { (_, _, e) in
                        event = e
                    }
                    
                    Tracker.setDelegate(delegate)
                    KarteApp.setup(appKey: APP_KEY)
                    
                    module.wait()
                }
                
                it("event name is `native_app_open`") {
                    expect(event.eventName).to(equal(.nativeAppOpen))
                }
                
                it("values.foo is `bar`") {
                    expect(event.values.string(forKey: "foo")).to(equal("bar"))
                }
            }
        }
    }
}
