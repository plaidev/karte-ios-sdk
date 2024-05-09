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

internal class LogLayout {
    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMddHHmmssSSS", options: 0, locale: nil)
        return formatter
    }()
    final var timestamp: String {
        Self.dateFormatter.string(for: Date()) ?? ""
    }
    func layout(_ log: Logger.Log) -> String { "" }
    deinit {}
}

internal class DevelopmentLogLayout: LogLayout {
    override func layout(_ log: Logger.Log) -> String {
        "\(timestamp) - \(log.tag.version) - \(log.level.identifier)/KARTE \(log.file):\(log.line) \(log.function) [\(log.tag.rawValue)] \(log.message)"
    }
    deinit {}
}

internal class ProductionLogLayout: LogLayout {
    override func layout(_ log: Logger.Log) -> String {
        "\(timestamp) - \(log.tag.version) - \(log.level.identifier)/KARTE [\(log.tag.rawValue)] \(log.message)"
    }
    deinit {}
}
