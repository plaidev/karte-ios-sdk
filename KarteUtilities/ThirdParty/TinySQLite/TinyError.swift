//
//  TinyError.swift
//  TinySQLite
//
//  Created by Øyvind Grimnes on 13/02/17.
//  Copyright © 2017 Øyvind Grimnes. All rights reserved.
//

import Foundation

public enum TinyError: Error {
    case databaseIsClosed(message: String)
    
    case invalidQuery(query: String)
    
    case nestedTransactions
    case noTransactionInProgress
    case transactionInProgress(message: String)
    
    case failedToBindParameters(message: String)
    
    case other(message: String)
}
