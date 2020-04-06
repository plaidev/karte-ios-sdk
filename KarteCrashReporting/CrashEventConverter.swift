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
import KarteCore

internal enum CrashEventConverter {
    static func convert(from crashReport: KRTPLCrashReport) -> Event? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970

        guard let data = try? encoder.encode(ErrorInfo(crashReport: crashReport)) else {
            return nil
        }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        guard let errorInfo = object as? [String: Any] else {
            return nil
        }

        let values = [
            "error_info": JSONConvertibleConverter.convert(errorInfo)
        ]
        return Event(eventName: .nativeAppCrashed, values: values)
    }
}

extension CrashEventConverter {
    struct ErrorInfo: Codable {
        var type: String?
        var code: String?
        var name: String?
        var reason: String?
        var symbols: String?
        var crashDate: Date?

        init(crashReport: KRTPLCrashReport) {
            let report = KRTCrashReport(crashReport: crashReport)
            self.type = report.type
            self.code = report.code
            self.name = report.name
            self.reason = report.reason
            self.symbols = report.symbols
            self.crashDate = report.timestamp
        }
    }
}
