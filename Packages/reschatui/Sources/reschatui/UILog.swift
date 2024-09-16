//
//  UILog.swift
//
//
//  Created by Mihaela MJ on 03.09.2024..
//

import Foundation
import ResChatAttributedText

extension UIMessage {
    public func toDictionary() -> [String: Any] {
        var _rawText = rawText ?? "-"
        var dict: [String: Any] = [
            "text": text,
            "rawText": _rawText,
            "type": type.stringValue,
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
    
    // MARK: Static -
    
    static func saveAsJSON() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: log, options: .prettyPrinted)
            try jsonData.write(to: logFileURL)
//            print("\(Self.logPrefix): Saved log to: \(logFileURL.absoluteString)")
        } catch {
            print("\(Self.logPrefix): Error saving log: \(error)")
        }
    }
    
    static func append(_ logEntry: LogEntry) {
        guard active else { return }
        // Create a mutable copy of the log entry and prepend the date
        var modifiedLogEntry = logEntry
        modifiedLogEntry["date"] = currentDate()

        // Add the modified log entry at the beginning of the log (if order matters here)
        log.insert(modifiedLogEntry, at: 0)
        log.append(logEntry)
        saveAsJSON()
//        AttributedTextCache.shared.saveAttributedStringsToDisk()
        AttributedTextCache.shared.saveToDisk()
    }
    
    static func deleteLog() {
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


extension UILog {
    // MARK: Actions:
    
    func logMessageAction(name: String, 
                          newMessage: UIMessage? = nil,
                          newMessages: [UIMessage]? = nil,
                          myMessages: [UIMessage]? = nil) {
        print("\(Self.logPrefix): UILog  \(name)")
        var logEntry: LogEntry = [ "_Message" : name]
        
        print("\(Self.logPrefix): \(name): `\(Self.summarizeString(newMessage?.text, upTo: 8) ?? "")`")
        
        logEntry["date"] = Self.currentDate()
        
        if let newMessage = newMessage {
            logEntry["newMessage"] = newMessage.toDictionary()
        }
        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        Self.append(logEntry)
    }
    
    func logSnapshotAction(name: String, 
                           newMessage: UIMessage? = nil,
                           newMessages: [UIMessage]? = nil,
                           myMessages: [UIMessage]? = nil,
                           messagePart: Int? = nil) {
        if Self.active {
            print("\(Self.logPrefix): UILog \(name)")
        }
        var logEntry: LogEntry = ["_Snapshot" : name]
        if Self.active {
            print("\(Self.logPrefix): \(name): `\(Self.summarizeString(newMessage?.text, upTo: 8) ?? "")`")
        }
        
        logEntry["date"] = Self.currentDate()
        
        if let newMessage = newMessage {
            logEntry["newMessage"] = newMessage.toDictionary()
        }
        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        if let messagePart = messagePart {
            logEntry["messagePart"] = messagePart
        }
        Self.append(logEntry)
    }
    
    func logHandleMessages(newMessages: [UIMessage]? = nil,
                           myMessages: [UIMessage]? = nil,
                           toReload: [UIMessage]? = nil,
                           toAppend: [UIMessage]? = nil,
                           toRemove: [UIMessage]? = nil,
                           finalResult: [UIMessage]? = nil) {
        if Self.active {
            print("\(Self.logPrefix): UILog \("HandleMessages")")
        }
        var logEntry: LogEntry = ["_Snapshot" : "HandleMessages"]
        logEntry["date"] = Self.currentDate()
        
        if Self.active {
            print("\(Self.logPrefix): HandleMessages: new:`\(newMessages?.count ?? 0)`, my: \(myMessages?.count ?? 0)")
        }

        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        
        if let toReload = toReload {
            logEntry["toReload"] = toReload.map { $0.toDictionary() }
        }
        if let toAppend = toAppend {
            logEntry["toAppend"] = toAppend.map { $0.toDictionary() }
        }
        if let toRemove = toRemove {
            logEntry["toRemove"] = toRemove.map { $0.toDictionary() }
        }
        if let finalResult = finalResult {
            logEntry["finalResult"] = finalResult.map { $0.toDictionary() }
        }

        Self.append(logEntry)
    }
    
    func logStreamingMessage(_ message: UIMessage, myMessages: [UIMessage]? = nil) {
        if Self.active {
            print("\(Self.logPrefix): StreamingMessage: `\(Self.summarizeString(message.text, upTo: 8) ?? "")`")
        }
        
        var logEntry: LogEntry = ["_Snapshot" : "StreamingMessage"]
        logEntry["date"] = Self.currentDate()
        
        logEntry["streamingMessage"] = message.toDictionary()
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        Self.append(logEntry)
    }
    
    func logUpdatedMessage(_ message: UIMessage, myMessages: [UIMessage]? = nil) {
        if Self.active {
            print("\(Self.logPrefix): UpdatedMessage: `\(Self.summarizeString(message.text, upTo: 8) ?? "")`")
            if let rawText = message.rawText, message.isFinished {
                print("\(Self.logPrefix): UpdatedMessage: FINISHED!")
            }
        }
        
        var logEntry: LogEntry = ["_Snapshot" : "UpdatedMessage"]
        logEntry["date"] = Self.currentDate()
        
        logEntry["updatedMessage"] = message.toDictionary()
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        Self.append(logEntry)
    }
    
    func logStateAction(name: String, state: String) {
        if Self.active {
            print("\(Self.logPrefix): UILog \(name)")
            print("\(Self.logPrefix): State: `\(state)")
        }
        
        var logEntry: LogEntry = ["_State" : name]
        logEntry["date"] = Self.currentDate()
        
        logEntry["state"] = state
        Self.append(logEntry)
    }
    
    func logMessageMarkdown(message: UIMessage) {
        return
        let summary = Self.summarizeString(message.attributedText.string, upTo: 20)
        
        if Self.active {
            print("\(Self.logPrefix): UILog \("MessageMarkdown")")
            print("\(Self.logPrefix): Markdown: `\(summary)")
            return
        }
        
        var logEntry: LogEntry = ["_State" : "Message Markdown"]
        logEntry["date"] = Self.currentDate()
        logEntry["string"] = summary
        
        Self.append(logEntry)
    }
}
