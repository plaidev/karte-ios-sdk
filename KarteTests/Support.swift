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

import XCTest
import Quick
@testable import KarteCore
@testable import KarteVisualTracking
@testable import KarteUtilities

let APP_KEY = "dummy_application_key_from_code_"

let EMPTY_RESPONSE = {
    let emptyResponse: [String: JSONConvertible] = ["status": 200, "events": [], "messages": [], "options": [:]]
    return emptyResponse.mapValues { $0.jsonValue }
}()

extension URLRequest {
    
    func trackBodyParameters() -> TrackBodyParameters? {
        guard let data = httpBodyStream?.readfully() else {
            return nil
        }
        if data.isGzipped, let gunzipped = try? data.gunzipped() {
            return try? createJSONDecoder().decode(TrackBodyParameters.self, from: gunzipped)
        }

        return try? createJSONDecoder().decode(TrackBodyParameters.self, from: data)
    }
    
    func pairingRequestBodyParameters() -> PairingRequestBodyParameters? {
        guard let data = httpBodyStream?.readfully() else {
            return nil
        }        
        return try? createJSONDecoder().decode(PairingRequestBodyParameters.self, from: data)
    }
    
    func pairingHeartbeatRequestBodyParameters() -> PairingHeartbeatRequestBodyParameters? {
        guard let data = httpBodyStream?.readfully() else {
            return nil
        }
        return try? createJSONDecoder().decode(PairingHeartbeatRequestBodyParameters.self, from: data)
    }
}

extension TrackBodyParameters {
    
    func pick(_ eventName: EventName) -> Event? {
        return events.first { (event) -> Bool in
            return event.eventName == eventName
        }
    }
}

func decodeResponseBodyData(_ data: Data) -> TrackBodyParameters? {
    return try? createJSONDecoder().decode(TrackBodyParameters.self, from: data)
}

func buildCommand(event: Event = Event(eventName: EventName("test")), visitorId: String = "dummy-vis-id", pvId: PvId = PvId("dummy-pv-id"), sceneId: SceneId = SceneId("dummy-scene-id")) -> TrackingCommand {
    let task = TrackingTask(
        event: event,
        visitorId: visitorId,
        view: nil
    )
    
    let scene = TrackingCommand.Scene(
        pvId: pvId,
        originalPvId: PvId("dummy-original-pv-id"),
        sceneId: sceneId
    )
    
    let command = TrackingCommand(task: task, scene: scene)
    return command
}

extension InputStream {
    func readfully() -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        open()
        
        var amount = 0
        repeat {
            amount = read(&buffer, maxLength: buffer.count)
            if amount > 0 {
                result.append(buffer, count: amount)
            }
        } while amount > 0
        
        close()
        
        return result
    }
}

class DummyLibraryConfiguration: LibraryConfiguration {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class IDFA: IDFADelegate {
    var isEnabled: Bool
    var idfa: String
    
    init(isEnabled: Bool = true, idfa: String = "dummy_idfa") {
        self.isEnabled = isEnabled
        self.idfa = idfa
    }
    
    var isAdvertisingTrackingEnabled: Bool {
        return isEnabled
    }
    
    var advertisingIdentifierString: String? {
        return idfa
    }
}

//Trackのコマンドが規定数送信するまで待つための機能を持ったクラス。TrackClientSessionMockと同時に使用する必要がある
class CommandCountObserver {
    private var expectedCommandCount: Int
    private var commandCount = 0
    private var token: NSObjectProtocol?
    private var exp: XCTestExpectation
    private var spec: QuickSpec

    init(spec: QuickSpec, expectedCommandCount: Int = 2) {
        self.spec = spec
        self.expectedCommandCount = expectedCommandCount
        exp = self.spec.expectation(description: "Waiting for track commands to be sent.")
        token = NotificationCenter.test.addObserver(forName: TrackClientSessionMock.requestSentNotification, object: nil, queue: nil) { [weak self] (note) in
            guard let self = self else { return }

            if let count = note.object as? Int {
                self.commandCount += count
            } else {
                self.commandCount += 1
            }
            if self.commandCount == self.expectedCommandCount {
                exp.fulfill()
                NotificationCenter.test.removeObserver(self.token!)
            }
        }
    }

    func wait(timeout: TimeInterval = 10) {
        self.spec.wait(for:[self.exp], timeout: timeout)
    }
}
