//
//  Loggable+Example.swift
//  ResChatUtil
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation

struct SomeLog: @preconcurrency Loggable {
    
    @MainActor static var log: [LogEntry] = []
    static let logFileName = "_reschat_SomeLog_log.json"
    static let logPrefix = "DBGG: SomeLog->"
    static let logQueue = DispatchQueue(label: "com.example.SomeLoggQueue", attributes: .concurrent)

    #if DEBUG
    @MainActor static var active = true
    #else
    static var active = false
    #endif
    
    @MainActor
    static func logConnect(_ params: LogEntry) {
        guard active else { return }
        // Create a new log entry
        var logEntry = SendableLogEntry(["event": "connect"])
        logEntry["params"] = params.data
        
        // Create a copy of logEntry to avoid reference capture
        let logEntryCopy = logEntry
        
        // Dispatch to the queue
        logQueue.async(flags: .barrier) {
            // Print log information if logging is active
            print("\(Self.logPrefix): Connect, params: \(params.data)")
            
            // Append the copied log entry
            Self.append(logEntryCopy)
        }
    }
    
    static func logCustom(logEntryData: LogEntryData) {
        var modifiedLogEntryData = logEntryData
        modifiedLogEntryData["customParams"] = "customParams"
        
        let sendableLogEntry = SendableLogEntry(modifiedLogEntryData)
        logQueue.async(flags: .barrier) {
            Self.append(sendableLogEntry)
        }
    }
}

struct AnotherLog: @preconcurrency Loggable {
    @MainActor static var log: [LogEntry] = []
    static let logFileName = "_another_log.json"
    static let logPrefix = "DBGG: Another->"
    static let logQueue = DispatchQueue(label: "com.example.AnotherLogQueue", attributes: .concurrent)

    #if DEBUG
    @MainActor static var active = true
    #else
    static var active = false
    #endif
    
    static func logConnect(_ message: String) {
        logParams(["message": message], key: "action", name: "connect")
    }
}
