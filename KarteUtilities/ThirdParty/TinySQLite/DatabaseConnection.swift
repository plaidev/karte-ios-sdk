//
//  DatabaseConnection.swift
//  TinySQLite
//
//  Created by Øyvind Grimnes on 25/12/15.
//

import SQLite3



internal let SQLITE_STATIC    = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)


/** Responsible for opening and closing database connections, executing queries, and managing transactions */
open class DatabaseConnection {
    
    fileprivate var databaseHandle: OpaquePointer?
    fileprivate let location: URL
    
    open var isOpen: Bool
    open var isTransactionInProgress: Bool
    
    public init(location: URL) {
        self.location = location
        self.isOpen   = false
        self.isTransactionInProgress = false
    }
    
    /** Open the database connection */
    open func open() throws {
        try ResultHandler.verifyResult(code: sqlite3_open(location.path, &databaseHandle))
        
        isOpen = true
    }
    
    /** Close the database connection */
    open func close() throws {
        try ResultHandler.verifyResult(code: sqlite3_close(databaseHandle))
        
        databaseHandle = nil
        isOpen         = false
    }
    
    /**
     Prepare a statement for the provided query
     
     - parameter query:  an SQLite query
     
     - returns:          a prepared statement
     */
    open func statement(for query: String) throws -> Statement {
        
        guard let handle = databaseHandle else {
            throw TinyError.databaseIsClosed(message: "Call `open()` before trying to access the database")
        }
        
        let statement: Statement = Statement(query)
        
        do {
            try statement.prepareForDatabase(handle)
        } catch (TinyError.other(let message)) {
            if message.contains("SQLite returned result code 1") {
                throw TinyError.invalidQuery(query: query)
            }
            
            throw TinyError.other(message: message)
        } catch (let error) {
            throw error
        }
        
        return statement
    }
}

// MARK: - Transactions
extension DatabaseConnection {
    
    /** Begin a transaction */
    func beginTransaction() throws {
        guard isTransactionInProgress == false else {
            throw TinyError.transactionInProgress(message: "Nesting transactions causes a deadlock")
        }
        
        try statement(for: "BEGIN TRANSACTION")
            .executeUpdate()
            .finalize()
        
        isTransactionInProgress = true
    }
    
    /** End an ongoing transaction */
    func endTransaction() throws {
        guard isTransactionInProgress == true else {
            throw TinyError.noTransactionInProgress
        }
        
        try statement(for: "END TRANSACTION")
            .executeUpdate()
            .finalize()
        
        isTransactionInProgress = false
    }
    
    /** Rollback a transaction */
    func rollbackTransaction() throws {
        guard isTransactionInProgress == true else {
            throw TinyError.noTransactionInProgress
        }
        
        try statement(for: "ROLLBACK TRANSACTION")
            .executeUpdate()
            .finalize()
        
        isTransactionInProgress = false
    }
}

// MARK: - General
extension DatabaseConnection {
    
    /** Number of rows affected by INSERT, UPDATE, or DELETE since the database was opened */
    var numberOfChanges: Int {
        return Int(sqlite3_changes(databaseHandle))
    }
    
    /** Total number of rows affected by INSERT, UPDATE, or DELETE since the database was opened */
    var totalNumberOfChanges: Int {
        return Int(sqlite3_total_changes(databaseHandle))
    }
    
    /** Interrupts any pending database operations */
    public func interrupt() {
        sqlite3_interrupt(databaseHandle)
    }
}

// MARK: - Convenience
extension DatabaseConnection {
    
    /**
     Check if a table exists
     
     - parameter tableName: name of the table
     
     - returns: `true` if the database contains a table with the specified name
     */
    public func contains(table tableName: String) throws -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='table' AND name=?"
        
        return try resultExists(for: query, withParameters: [tableName])
    }
    
    /**
     Check if a table exists
     
     - parameter indexName: name of the index
     
     - returns: `true` if the database contains an index with the specified name
     */
    public func contains(index indexName: String) throws -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='index' AND name=?"
        
        return try resultExists(for: query, withParameters: [indexName])
    }
    
    /**
     Check if a table exists
     
     - parameter viewName: name of the view
     
     - returns: `true` if the database contains a view with the specified name
     */
    public func contains(view viewName: String) throws -> Bool {
        let query = "SELECT name FROM sqlite_master WHERE type='view' AND name=?"
        
        return try resultExists(for: query, withParameters: [viewName])
    }
    
    private func resultExists(for query: String, withParameters parameters: [SQLiteValue?]) throws -> Bool {
        let statement = try self.statement(for: query).execute(withParameters: parameters)
        
        /* Finalize the statement if necessary */
        defer {
            try! statement.finalize()
        }
        
        return statement.next() != nil
    }
}
