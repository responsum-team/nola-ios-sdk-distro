//
//  ProcessLog.swift
//  ResChatUICommon
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation
import ResChatUtil

struct ProcessLog: @preconcurrency Loggable {
    @MainActor static var log: [LogEntry] = []
    static let logFileName = "_messages_processing_log.json"
    static let logPrefix = "DBGG: ProcessLog->"
    static let logQueue = DispatchQueue(label: "com.example.ProcessLogQueue", attributes: .concurrent)

    #if DEBUG
    @MainActor static var active = true
    #else
    static var active = false
    #endif
    
    enum Action: String, CaseIterable {
        case processHistoryMessages
        case processStreamingMessage
        case processUpdatedMessage
    }
    
    /**
     action: processHistoryMessages
     action: processStreamingMessage
     action: processUpdatedMessage
     */
    
    static func logConnect(action: Action, subActionName: String) {
        var logEntry = ["subAction": subActionName]
        
        
//        logParams(["message": message], key: "action", name: "connect")
    }
}
