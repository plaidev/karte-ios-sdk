//
//  Copyright 2023 PLAID, Inc.
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

protocol InboxConfig {
    var baseUrl: URL { get }
}

struct ProductionConfig: InboxConfig {
    var baseUrl: URL {
        URL(string: "https://api.karte.io")!
    }
}

struct EvaluationConfig: InboxConfig {
    var baseUrl: URL {
        URL(string: "https://api-evaluation.dev-karte.com")!
    }
}
