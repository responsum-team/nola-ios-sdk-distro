//
//  Loggable.swift
//  ResChatUtil
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation

public typealias LogEntryData = [String: Any]

// Wrapper around [String: Any] to make it Sendable
public struct SendableLogEntry: @unchecked Sendable {
    var data: LogEntryData

    // Custom subscript to access and modify data
    public subscript(key: String) -> Any? {
        get {
            return data[key]
        }
        set {
            data[key] = newValue
        }
    }
    
    public init(_ data: [String: Any] = [:]) {
        self.data = data
    }
}

public protocol Loggable {
    typealias LogEntry = SendableLogEntry

    static var log: [LogEntry] { get set }
    static var logFileName: String { get }
    static var logPrefix: String { get }
    static var logQueue: DispatchQueue { get }

    static var active: Bool { get }

    static func saveAsJSON()
    static func loadFromJSON() -> [LogEntry]?
    static func loadFromJSONString(_ jsonString: String) -> [LogEntry]?
    static func loadFromFile(atPath path: String) -> [LogEntry]?
    static func append(_ logEntry: LogEntry)
    static func deleteLog()
}

// MARK: I/O -

public extension Loggable {

    // MARK: - Save Log as JSON
    
    static func saveAsJSON() {
        logQueue.async(flags: .barrier) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(logFileName)
            
            // Extract the data dictionaries from each log entry
            let jsonArray = log.map { $0.data }
            
            guard JSONSerialization.isValidJSONObject(jsonArray) else {
                print("\(logPrefix): Log is not a valid JSON object")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
                try jsonData.write(to: logFileURL)
            } catch {
                print("\(logPrefix): Error saving log: \(error)")
            }
        }
    }

    // MARK: - Load Log from JSON
    
    static func loadFromJSON() -> [LogEntry]? {
        logQueue.sync {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(logFileName)
            
            do {
                let data = try Data(contentsOf: logFileURL)
                return parseJSONData(data)
            } catch {
                print("\(logPrefix): Error loading log: \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Load Log from JSON String
    
    static func loadFromJSONString(_ jsonString: String) -> [LogEntry]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("\(logPrefix): Invalid JSON string.")
            return nil
        }
        return parseJSONData(jsonData)
    }
    
    // MARK: - Load Log from File
    
    static func loadFromFile(atPath path: String) -> [LogEntry]? {
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: path))
            return parseJSONData(fileData)
        } catch {
            print("\(logPrefix): Error loading log from file at path \(path): \(error)")
            return nil
        }
    }

    // MARK: - Helper Method for Parsing JSON Data
    
    private static func parseJSONData(_ jsonData: Data) -> [LogEntry]? {
        do {
            // Parse the data into an array of dictionaries
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                // Map dictionaries to SendableLogEntry instances
                let logEntries = jsonArray.map { SendableLogEntry($0) }
                log = logEntries
                return logEntries
            } else {
                print("\(logPrefix): Invalid JSON format.")
                return nil
            }
        } catch {
            print("\(logPrefix): Error parsing JSON data: \(error)")
            return nil
        }
    }
}

// MARK: Actions -

public extension Loggable {

    static func append(_ logEntry: LogEntry) {
        logQueue.async(flags: .barrier) {
            guard active else { return }

            var modifiedLogEntry = logEntry
            modifiedLogEntry["index"] = log.count
            modifiedLogEntry["date"] = Date.loggableCurrentDate()

            log.append(modifiedLogEntry)
            saveAsJSON()
        }
    }

    static func deleteLog() {
        logQueue.async(flags: .barrier) {
            log.removeAll()

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logFileURL = documentsPath.appendingPathComponent(logFileName)

            do {
                if FileManager.default.fileExists(atPath: logFileURL.path) {
                    try FileManager.default.removeItem(at: logFileURL)
                    print("\(logPrefix): Deleted log file at: \(logFileURL.absoluteString)")
                } else {
                    print("\(logPrefix): Log file does not exist at: \(logFileURL.absoluteString)")
                }
            } catch {
                print("\(logPrefix): Error deleting log file: \(error)")
            }
        }
    }
}

public extension Loggable {
    
    static func logParams(_ params: LogEntryData, key: String = "key", name: String = "name") {
        // Create a new log entry
        var logEntry = SendableLogEntry([key: name])
        logEntry["params"] = params
        
        // Create a copy of logEntry to avoid reference capture
        let logEntryCopy = logEntry
        
        if active { print("\(logPrefix): (\(key), \(name)), params: \(params)")  } // Print log information if logging is active
        
        // Dispatch to the queue
        logQueue.async(flags: .barrier) {
            // Append the copied log entry
            append(logEntryCopy)
        }
    }
    
    // Log custom data
    static func logCustom(logEntryData: LogEntryData) {
        // Create a SendableLogEntry from modified data
        let sendableLogEntry = SendableLogEntry(logEntryData)
        
        // Dispatch the append operation to the log queue
        logQueue.async(flags: .barrier) {
            Self.append(sendableLogEntry)
        }
    }
}
