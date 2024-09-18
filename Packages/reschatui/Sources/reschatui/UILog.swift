//
//  UILog.swift
//
//
//  Created by Mihaela MJ on 03.09.2024..
//

import Foundation
import ResChatAttributedText
import ResChatUICommon

extension UIMessage {
    public func toDictionary() -> [String: Any] {
        var _rawText = rawText ?? "-"
        var dict: [String: Any] = [
            "text": text,
            "attributedText": attributedText.string,
            "type": type.stringValue,
            "origin": origin.rawValue,
            "messagePart": "\(messagePart)",
            "messageIndex": "\(messageIndex)",
            "isBot": "\(isBot ? "true" : "false")",
            "isPlaceholder": "\(isPlaceholder ? "true" : "false")",
            "isFinished": "\(isFinished ? "true" : "false")",
            "timestamp": timestamp,
        ]
        return dict
    }
}

struct UILog {
    
    typealias LogEntry = [String: Any]
    
    static func currentDate() -> String {
        // Get the current date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        return currentDate
    }
    
    static func summarizeString(_ input: String?, upTo count: Int) -> String? {
        guard let input = input else { return nil }
        let prefixString = String(input.prefix(count))
        let remainingCharacters = input.count - prefixString.count
        let summary = "\(prefixString) (+ \(remainingCharacters) characters)"
        return summary
    }
    
    // MARK: Properties -
    
    static var log: [LogEntry] = []
    static let logFileName = "_reschat_UI_log.json"
    static let logPrefix = "DBGG: UI_Event-> "
    
    #if DEBUG
    private static var active = false
    #else
    private static var active = false
    #endif
    
    public static let shared = UILog()
    
    // MARK: Synchronization Queue -
    private static let logQueue = DispatchQueue(label: "com.example.UILogQueue", attributes: .concurrent)
    
    // MARK: Static -
    
    static func saveAsJSON() {
        logQueue.async(flags: .barrier) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: log, options: .prettyPrinted)
                try jsonData.write(to: logFileURL)
            } catch {
                print("\(Self.logPrefix): Error saving log: \(error)")
            }
        }
    }
    
    static func append(_ logEntry: LogEntry) {
        logQueue.async(flags: .barrier) {
            guard active else { return }
            // Create a mutable copy of the log entry and assign the index
            var modifiedLogEntry = logEntry
            modifiedLogEntry["index"] = log.count // Assign the index as the current size of the log
            modifiedLogEntry["date"] = currentDate()
            // Append the modified log entry
            log.append(modifiedLogEntry)
            saveAsJSON()
        }
    }
    
    static func deleteLog() {
        logQueue.async(flags: .barrier) {
            // Clear the in-memory log
            log.removeAll()
            
            // Delete the log file from the file system
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)
            
            do {
                if FileManager.default.fileExists(atPath: logFileURL.path) {
                    try FileManager.default.removeItem(at: logFileURL)
                    print("\(Self.logPrefix): Deleted log file at: \(logFileURL.absoluteString)")
                } else {
                    print("\(Self.logPrefix): Log file does not exist at: \(logFileURL.absoluteString)")
                }
            } catch {
                print("\(Self.logPrefix): Error deleting log file: \(error)")
            }
        }
    }
}


extension UILog {
    func logHistoryMessages(receivedMessages: [UIMessage]? = nil,
                            currentMessages: [UIMessage]? = nil,
                            updatedMessages: [UIMessage]? = nil) {
        var logEntry: LogEntry = ["_Processing" : "HistoryMessages"]

        if let receivedMessages = receivedMessages {
            logEntry["receivedMessages"] = receivedMessages.map { $0.toDictionary() }
        }
        if let currentMessages = currentMessages {
            logEntry["currentMessages"] = currentMessages.map { $0.toDictionary() }
        }
        if let updatedMessages = updatedMessages {
            logEntry["updatedMessages"] = updatedMessages.map { $0.toDictionary() }
        }

        Self.append(logEntry)
    }
    
    func logStreamingMessage(_ message: UIMessage) {
        var logEntry: LogEntry = ["_Processing" : "StreamingMessage"]
        logEntry["streamingMessage"] = message.toDictionary()
        Self.append(logEntry)
    }
    
    func logUpdatedMessage(_ message: UIMessage) {
        var logEntry: LogEntry = ["_Processing" : "UpdatedMessage"]
        logEntry["updatedMessage"] = message.toDictionary()
        Self.append(logEntry)
    }
    
    func loadPlaceholderMessage(_ message: UIMessage) {
        var logEntry: LogEntry = ["_Processing" : "LoadPlaceholderMessage"]
        logEntry["PlaceholderMessage"] = message.toDictionary()
        logEntry["type"] = message.type.stringValue
        Self.append(logEntry)
    }
    
}
