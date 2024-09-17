//
//  TrafficLog.swift
//  
//
//  Created by Mihaela MJ on 27.08.2024..
//

import Foundation
import SocketIO

struct TrafficLog {
    
    typealias LogEntry = [String: Any]
    
    static func currentDate() -> String {
        // Get the current date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        return currentDate
    } 
    
    // MARK: Properties -
    
    static var log: [LogEntry] = []
    static let logFileName = "_reschat_network_log.json"
    static let logPrefix = "DBGG: Traffic->"
    
    #if DEBUG
    private static var active = true
    #else
    private static var active = false
    #endif
    
    public static let shared = TrafficLog()
    
    // MARK: Synchronization Queue -
    private static let logQueue = DispatchQueue(label: "com.example.TrafficLogQueue", attributes: .concurrent)
    
    // MARK: Loading -
    
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
    
    static func loadFromJSON() -> [LogEntry]? {
        logQueue.sync {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)

            do {
                let data = try Data(contentsOf: logFileURL)
                let jsonLog = try JSONSerialization.jsonObject(with: data, options: []) as? [LogEntry]
                return jsonLog
            } catch {
                print("\(Self.logPrefix): Error loading log: \(error)")
                return nil
            }
        }
    }
    
    // Load log entries from a JSON string
    static func loadFromJSONString(_ jsonString: String) -> [LogEntry]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("\(Self.logPrefix): Invalid JSON string.")
            return nil
        }
        
        do {
            let jsonLog = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [LogEntry]
            log = jsonLog ?? []
            return jsonLog
        } catch {
            if Self.active {
                print("\(Self.logPrefix): Error parsing JSON string: \(error)")
            }
            return nil
        }
    }

    // Load log entries from a file at a specified path
    static func loadFromFile(atPath path: String) -> [LogEntry]? {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: path))
            let jsonLog = try JSONSerialization.jsonObject(with: fileData, options: []) as? [LogEntry]
            log = jsonLog ?? []
            return jsonLog
        } catch {
            print("\(Self.logPrefix): Error loading log from file at path \(path): \(error)")
            return nil
        }
    }
    
    // MARK: Log Actions -
    
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
    
    // MARK: Actions:
    
    func logConnect(params: LogEntry) {
        var logEntry: LogEntry = [ "event" : ResChatSocket.SocketEventKey.connect.rawValue]
        
        if Self.active {
            print("\(Self.logPrefix): \(ResChatSocket.SocketEventKey.connect.rawValue), params: `\(params)`")
        }
        
        logEntry["params"] = params
        Self.append(logEntry)
    }
    
    func logDisconnect() {
//        let logEntry: LogEntry = [ "event" : ResChatSocket.SocketEventKey.disconnect.rawValue]
//        Self.append(logEntry)
    }
    
    func logError(name: String,
                  error: Error? = nil) {
        var logEntry: LogEntry = [ "_Error" : name]
        
        if Self.active {
            print("\(Self.logPrefix): \(name)")
        }
        
        if let error = error {
            logEntry["description"] = error.localizedDescription
        }
        Self.append(logEntry)
    }
    
    func logEmitMessage(key: String, payload: [String: Any]) {
        var logEntry: LogEntry = [ "event" : "emitMessage"]
        logEntry["key"] = key
        logEntry["payload"] = payload
        
        if Self.active {
            print("\(Self.logPrefix): emitMessage, `\(key)`, payload: \(payload)")
        }
        
        Self.append(logEntry)
    }
    
    func logSocketCallback(key: String, payload: [String: Any], response: [Any]) {
        var logEntry: LogEntry = [ "event" : "callback"]
        
        if Self.active {
            print("\(Self.logPrefix): callback, `\(key)`, payload: \(payload), response: \(response)")
        }
        
        logEntry["key"] = key
        logEntry["payload"] = payload
        logEntry["response"] = response
        Self.append(logEntry)
    }
    
    func logOnResponse(named: String, data: [Any]) {
        var logEntry: LogEntry = [ "event" : "on \(named)"]
        
        if Self.active {
            print("\(Self.logPrefix): OnResponse, `\(named)`")
        }
        
        logEntry["data"] = data
        Self.append(logEntry)
    }
    
    // MARK: helper -
    
    static func eventName(from logEntry: TrafficLog.LogEntry) -> String? {
        if let eventName = logEntry["event"] as? String {
            return eventName
        } else {
            return nil
        }
    }
}

class SocketEventReplayer {
    
    static let logPrefix = "Replay: "

    private var logEntries: [TrafficLog.LogEntry]
    private var currentIndex: Int = -1
    private let socket: ResChatSocket
    private let eventsToSkip: Set<String>
    
    public var hasMore: Bool {
        !logEntries.isEmpty
    }

    init(socket: ResChatSocket, logEntries: [TrafficLog.LogEntry], eventsToSkip: Set<String> = []) {
        self.socket = socket
        self.logEntries = logEntries
        self.eventsToSkip = eventsToSkip
        
        print("\(Self.logPrefix): TrafficLog entries: \(logEntries.count)")
    }
    
    func next() {
        while !logEntries.isEmpty {
            currentIndex = currentIndex + 1
            let logEntry = logEntries.removeFirst()
            
            guard let event = logEntry["event"] as? String else {
                print("Invalid log entry: \(logEntry)")
                continue
            }

            if eventsToSkip.contains(event) {
                print("Skipping event: \(event)")
                continue
            }
            let eventName = TrafficLog.eventName(from: logEntry) ?? "N/A"
            print("\(Self.logPrefix): Replaying: [\(currentIndex)]: \(eventName)")
            replay(logEntry)
            break
        }
    }

    private func replay(_ logEntry: TrafficLog.LogEntry) {
        guard let event = logEntry["event"] as? String else {
            print("Invalid log entry: \(logEntry)")
            return
        }
        let cleanEventName: String = {
            if event.hasPrefix("on ") {
                return String(event.dropFirst(3))
            } else {
                return event
            }
        }()
        
        switch cleanEventName {
        case ResChatSocket.SocketEventKey.connect.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.onConnect(data: data)
            }
        case ResChatSocket.SocketEventKey.disconnect.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.onDisconnect(data: data)
            }
        case ResChatSocket.SocketEventKey.error.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.onError(data: data)
            }
        case ResChatSocket.SocketEventKey.sendHistorySnapshot.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.handleReceivedConversations(data: data)
            }
        case ResChatSocket.SocketEventKey.streamMessage.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.handleReceivedStreamMessages(data: data)
            }
        case ResChatSocket.SocketEventKey.updateHistoryItem.rawValue:
            if let data = logEntry["data"] as? [Any] {
                socket.handleReceivedUpdateHistoryItems(data: data)
            }
        default:
            print("Unknown event: \(event)")
        }
    }
}

/**
 let eventsToSkip: Set<String> = [
     ResChatSocket.SocketEventKey.disconnect.rawValue,
     // Add other events to skip as needed
 ]

 let eventReplayer = SocketEventReplayer(socket: socket, logEntries: logEntries, eventsToSkip: eventsToSkip)

 while eventReplayer.currentIndex < logEntries.count {
     eventReplayer.next()
 }
 */
