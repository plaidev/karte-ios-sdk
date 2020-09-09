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

internal class ConsoleLogAppender: LogAppender {
    enum Mode {
        case production
        case development
    }
    var mode: Mode = .production
    let productionLayout = ProductionLogLayout()
    let developmentLayout = DevelopmentLogLayout()

    func append(_ log: Logger.Log) {
        if Logger.level < log.level || !Logger.isEnabled {
            return
        }

        switch mode {
        case .production:
            print(productionLayout.layout(log))

        case .development:
            print(developmentLayout.layout(log))
        }
    }
    deinit {}
}
