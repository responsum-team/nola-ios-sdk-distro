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
    @MainActor static var active = false
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
    
    static func log(action: Action,
                    subActionName: String,
                    message: UIMessage? = nil,
                    messages: [UIMessage]? = nil) {

        var logEntry: LogEntryData = ["action": action.rawValue]
        logEntry["subAction"] = subActionName
        if let message = message {
            logEntry["message"] = message.toDictionary()
        }
        if let messages = messages {
            logEntry["messages"] = messages.map { $0.toDictionary() }
        }
        let sendableLogEntry = SendableLogEntry(logEntry)
        logQueue.async(flags: .barrier) {
            Self.append(sendableLogEntry)
        }
    }
}


