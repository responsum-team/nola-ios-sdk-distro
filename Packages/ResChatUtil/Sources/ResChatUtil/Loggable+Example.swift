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
}
