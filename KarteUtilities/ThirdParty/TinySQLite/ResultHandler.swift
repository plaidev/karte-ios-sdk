//
//  ResultHandler.swift
//  TinySQLite
//
//  Created by Øyvind Grimnes on 13/02/17.
//  Copyright © 2017 Øyvind Grimnes. All rights reserved.
//

import Foundation
import SQLite3


internal struct ResultHandler {
    static let successCodes: Set<Int32> = [SQLITE_OK, SQLITE_DONE, SQLITE_ROW]
    
    private static func isSuccess(_ resultCode: Int32) -> Bool {
        return ResultHandler.successCodes.contains(resultCode)
    }
    
    static func verifyResult(code resultCode: Int32) throws {
        guard isSuccess(resultCode) else {
            throw TinyError.other(message: "SQLite returned result code \(resultCode), indicating an error. SQLite result codes are described here: https://www.sqlite.org/c3ref/c_abort.html")
        }
    }
}
