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
import UIKit

internal struct Trigger: Codable {
    var condition: LogicalOperator
    var fields: [String: String]
    var dynamicFields: [DynamicField]?

    func dynamicValues(window: UIWindow?) -> [String: JSONConvertible]? {
        guard let dynamicFields = self.dynamicFields,
              let window = window,
              !dynamicFields.isEmpty else {
            return nil
        }
        var result: [String: JSONConvertible] = [:]
        for dynamicField in dynamicFields {
            guard let dynamicFieldActionId = dynamicField.actionId,
                  let dynamicFieldName = dynamicField.name
            else {
                return nil
            }

            let viewPath = UIKitAction.viewPathIndices(actionId: dynamicFieldActionId)
            let view = Inspector.inspectView(with: viewPath, inWindow: window)
            let actionId = UIKitAction.actionId(view: view)
            if dynamicFieldActionId == actionId,
               let targetText = Inspector.inspectText(with: view) {
                result[dynamicFieldName] = targetText
            }
        }

        return result
    }

    func match(data: [String: JSONValue]) -> Bool {
        condition.match(data: data)
    }
}

extension Trigger {
    enum CodingKeys: String, CodingKey {
        case condition
        case fields
        case dynamicFields = "dynamic_fields"
    }
}
