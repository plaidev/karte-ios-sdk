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
import KarteUtilities

internal struct PubSubTableSchema: SQLiteTableSchema {
    var database: SQLiteDatabase

    var name: String {
        "pubsub_messages"
    }

    var columns: [SQLiteColumn] {
        [
            SQLiteColumn("message_id", type: .text, constraints: "PRIMARY KEY"),
            SQLiteColumn("publisher_id", type: .text, constraints: "NOT NULL"),
            SQLiteColumn("process_id", type: .text, constraints: "NOT NULL"),
            SQLiteColumn("data", type: .none, constraints: "NOT NULL"),
            SQLiteColumn("is_ready_on_background", type: .integer, constraints: "NOT NULL"),
            SQLiteColumn("created_at", type: .real, constraints: "NOT NULL"),
            SQLiteColumn("updated_at", type: .real, constraints: "NOT NULL")
        ]
    }

    init(_ database: SQLiteDatabase) {
        self.database = database
    }
}
