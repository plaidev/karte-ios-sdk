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

import Foundation
import Quick

struct StubResource {
    var resource: String
    var `extension`: String
    
    init(_ name: String) {
        let components = name.split(separator: ".")
        self.resource = String(components[0])
        self.extension = String(components[1])
    }
    
    func url(bundle: Bundle) -> URL? {
        return bundle.url(forResource: resource, withExtension: self.extension)
    }
    
    func data(bundle: Bundle) -> Data? {
        return url(bundle: bundle).flatMap { try? Data(contentsOf: $0) }
    }
}

extension StubResource {
    static var empty = StubResource("success_empty.json")
    static var failure_invalid_request = StubResource("failure_invalid_request.json")
    static var failure_server_error = StubResource("failure_server_error.json")
    static var variables1 = StubResource("success_variables_1.json")
    static var variables2 = StubResource("success_variables_2.json")
    static var variables3 = StubResource("success_variables_3.json")
    static var vt1 = StubResource("success_vt_1.json")
    static var vt2 = StubResource("success_vt_2.json")
    static var vt_definitions = StubResource("success_vt_definitions.json")
    static var vt_definitions_with_dynamic_fields = StubResource("success_vt_definitions_with_dynamic_fields.json")
    static var inbox_success = StubResource("success_inbox.json")
}
