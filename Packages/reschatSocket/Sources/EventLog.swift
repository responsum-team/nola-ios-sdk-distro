//
//  EventLog.swift
//
//
//  Created by Mihaela MJ on 09.09.2024..
//

import Foundation

extension SocketMessage {
    public func toDictionary() -> [String: Any] {
        var _rawText = rawText ?? "-"
        var dict: [String: Any] = [
            "text": text,
            "rawText": _rawText,
            "socketSource": socketSource.rawValue,
            "messagePartNumber": "\(messagePartNumber)",
            "messageIndex": "\(messageIndex)",
            "isBot": "\(isBotMessage ? "true" : "false")",
            "isMessageFinished": "\(isMessageFinished ? "true" : "false")",
            "timestamp": messageTimestamp,
        ]
        return dict
    }
}

struct EventLog {
    
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
    static let logFileName = "_reschat_event_log.json"
    static let logPrefix = "DBGG: Event->"
    
#if DEBUG
    private static var active = false
#else
    private static var active = false
#endif
    
    public static let shared = EventLog()
    
    // MARK: Synchronization Queue -
    private static let logQueue = DispatchQueue(label: "com.example.EventLogQueue", attributes: .concurrent)
    
    
    // MARK: Static -
    
    static func saveAsJSON() {
        logQueue.async(flags: .barrier) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)
            
            guard JSONSerialization.isValidJSONObject(log) else {
                print("\(Self.logPrefix): Log is not a valid JSON object")
                return
            }

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
            log.append(logEntry)
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

extension EventLog {
    static let nameReceivedConversations = "Received_Conversations"
    static let nameReceivedStreamMessage = "Received_StreamMessages"
    static let nameReceivedUpdateHistoryItems = "Received_UpdateHistoryItems"
    
    func logEvent(name: String,
                  newMessage: SocketMessage? = nil,
                  newMessages: [SocketMessage]? = nil,
                  myMessages: [SocketMessage]? = nil) {
        if Self.active {
            print("\(Self.logPrefix): \(name)")
        }
        
        var logEntry: LogEntry = [ "_Event" : name]
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
    
    func logError(name: String,
                  error: Error? = nil) {
        var logEntry: LogEntry = [ "_Error" : name]
        logEntry["date"] = Self.currentDate()
        
        if Self.active {
            print("\(Self.logPrefix): \(name)")
        }
        
        if let error = error {
            logEntry["description"] = error.localizedDescription
        }
        Self.append(logEntry)
    }
    

    func logReceivedConversationsError(_ error: Error? = nil) {
        logError(name: Self.nameReceivedConversations, error: error)
    }
    
    func logReceivedStreamMessagesError(_ error: Error? = nil) {
        logError(name: Self.nameReceivedStreamMessage, error: error)
    }
    
    func logReceivedUpdateHistoryItemsError(_ error: Error? = nil) {
        logError(name: Self.nameReceivedUpdateHistoryItems, error: error)
    }
    
    func logEventReceivedConversations(snapshot: HistorySnapshot,
                                       historyFinishedLoading: Bool,
                                       newMessages: [SocketMessage]? = nil,
                                       myMessages: [SocketMessage]? = nil) {
        var logEntry: LogEntry = [ "_HandleEvent" : Self.nameReceivedConversations]
        logEntry["date"] = Self.currentDate()
        
        if Self.active {
            print("\(Self.logPrefix): \(Self.nameReceivedStreamMessage): `\(snapshot.messages.count)`, messagesBefore = \(snapshot.messagesBefore)")
        }
        
        logEntry["messagesBefore"] = "\(snapshot.messagesBefore)"
        logEntry["messagesAfter"] = "\(snapshot.messagesAfter)"
        logEntry["historyFinishedLoading"] = "\(historyFinishedLoading ? "true" : "false")"
        
        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        
        if let startMessages = myMessages, let endMessages = newMessages {
            let diffMessages = calculateDifferences(between: startMessages, and: endMessages)
            logEntry["diffMessages"] = diffMessages.map { $0.toDictionary() }
        }
        Self.append(logEntry)
    }
    
    
    func logEventReceivedStreamMessages(newMessage: SocketMessage? = nil, 
                                        newMessages: [SocketMessage]? = nil,
                                        myMessages: [SocketMessage]? = nil) {
        return
        var logEntry: LogEntry = [ "_HandleEvent" : Self.nameReceivedStreamMessage]
        
        if Self.active {
            print("\(Self.logPrefix): \(Self.nameReceivedStreamMessage): (part: \(newMessage?.messagePartNumber)`\(Self.summarizeString(newMessage?.text, upTo: 8) ?? "")`")
        }
        
        logEntry["date"] = Self.currentDate()
        
        if let newMessage = newMessage {
            logEntry["streamMessage"] = newMessage.toDictionary()
        }
        
        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        
        if let startMessages = myMessages, let endMessages = newMessages {
            let diffMessages = calculateDifferences(between: startMessages, and: endMessages)
            logEntry["diffMessages"] = diffMessages.map { $0.toDictionary() }
        }
        
        Self.append(logEntry)
    }
    
    func logEventUpdateHistoryItems(newMessage: SocketMessage? = nil,
                                    newMessages: [SocketMessage]? = nil,
                                    myMessages: [SocketMessage]? = nil) {
        var logEntry: LogEntry = [ "_HandleEvent" : Self.nameReceivedUpdateHistoryItems]
        
        if Self.active {
            print("\(Self.logPrefix): \(Self.nameReceivedUpdateHistoryItems): `\(Self.summarizeString(newMessage?.text, upTo: 8) ?? "")`")
        }
        
        logEntry["date"] = Self.currentDate()
        
        if let newMessage = newMessage {
            logEntry["updatedMessage"] = newMessage.toDictionary()
        }
        
        if let newMessages = newMessages {
            logEntry["newMessages"] = newMessages.map { $0.toDictionary() }
        }
        if let myMessages = myMessages {
            logEntry["myMessages"] = myMessages.map { $0.toDictionary() }
        }
        
        if let startMessages = myMessages, let endMessages = newMessages {
            let diffMessages = calculateDifferences(between: startMessages, and: endMessages)
            logEntry["diffMessages"] = diffMessages.map { $0.toDictionary() }
        }
        
        Self.append(logEntry)
    }
    
}

private extension EventLog {
    func calculateDifferences<T: Equatable>(between oldArray: [T], and newArray: [T]) -> [T] {
        // Find elements that are in newArray but not in oldArray
        let addedOrUpdatedItems = newArray.filter { !oldArray.contains($0) }
        
        // Find elements that are in oldArray but not in newArray (for potential removal or reference)
        let removedItems = oldArray.filter { !newArray.contains($0) }
        
        // Combine the added/updated items and removed items into a single array for the final diff
        let differences = addedOrUpdatedItems + removedItems
        
        return differences
    }
}
