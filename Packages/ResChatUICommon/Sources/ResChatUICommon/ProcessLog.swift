////
////  ProcessLog.swift
////  ResChatUICommon
////
////  Created by Mihaela MJ on 18.09.2024..
////
//
//import Foundation
//
//struct ProcessLog {
//    typealias LogEntry = [String: Any]
//    
//    static func currentDate() -> String {
//        // Get the current date as a string
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm:ss"
//        let currentDate = dateFormatter.string(from: Date())
//        return currentDate
//    }
//    
//    static var log: [LogEntry] = []
//    static let logFileName = "_messages_processing_log.json"
//    static let logPrefix = "DBGG: ProcessLog->"
//    static let logQueue = DispatchQueue(label: "com.example.ProcessLogQueue", attributes: .concurrent)
//    
//#if DEBUG
//    private static let active = true
//#else
//    private static let active = false
//#endif
//    
//    public static let shared = ProcessLog()
//}
//    
//// MARK: I/O -
//
//extension ProcessLog {
//   
//    static func saveAsJSON() {
//        logQueue.async(flags: .barrier) {
//            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)
//            
//            guard JSONSerialization.isValidJSONObject(log) else {
//                print("\(Self.logPrefix): Log is not a valid JSON object")
//                return
//            }
//            
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: log, options: .prettyPrinted)
//                try jsonData.write(to: logFileURL)
//            } catch {
//                print("\(Self.logPrefix): Error saving log: \(error)")
//            }
//        }
//    }
//    
//    static func loadFromJSON() -> [LogEntry]? {
//        logQueue.sync {
//            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)
//            
//            do {
//                let data = try Data(contentsOf: logFileURL)
//                let jsonLog = try JSONSerialization.jsonObject(with: data, options: []) as? [LogEntry]
//                return jsonLog
//            } catch {
//                print("\(Self.logPrefix): Error loading log: \(error)")
//                return nil
//            }
//        }
//    }
//    
//    // Load log entries from a JSON string
//    static func loadFromJSONString(_ jsonString: String) -> [LogEntry]? {
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            print("\(Self.logPrefix): Invalid JSON string.")
//            return nil
//        }
//        
//        do {
//            let jsonLog = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [LogEntry]
//            log = jsonLog ?? []
//            return jsonLog
//        } catch {
//            if Self.active {
//                print("\(Self.logPrefix): Error parsing JSON string: \(error)")
//            }
//            return nil
//        }
//    }
//    
//    // Load log entries from a file at a specified path
//    static func loadFromFile(atPath path: String) -> [LogEntry]? {
//        do {
//            let fileData = try Data(contentsOf: URL(fileURLWithPath: path))
//            let jsonLog = try JSONSerialization.jsonObject(with: fileData, options: []) as? [LogEntry]
//            log = jsonLog ?? []
//            return jsonLog
//        } catch {
//            print("\(Self.logPrefix): Error loading log from file at path \(path): \(error)")
//            return nil
//        }
//    }
//}
//
//// MARK: Logging -
//    
//extension ProcessLog {
//    
//    enum Action: String, CaseIterable {
//        case processHistoryMessages
//        case processStreamingMessage
//        case processUpdatedMessage
//    }
//    
//    func log(action: Action,
//                    subActionName: String,
//                    message: UIMessage? = nil,
//                    messages: [UIMessage]? = nil) {
//
//        var logEntry: LogEntry = ["action": action.rawValue]
//        logEntry["subAction"] = subActionName
//        if let message = message {
//            logEntry["message"] = message.toDictionary()
//        }
//        if let messages = messages {
//            logEntry["messages"] = messages.map { $0.toDictionary() }
//        }
//
//        Self.append(logEntry)
//    }
//}
//
//// MARK: Log Actions -
//
//extension ProcessLog {
//    
//    static func append(_ logEntry: LogEntry) {
//        guard active else { return }
//
//        logQueue.async(flags: .barrier) {
//            var modifiedLogEntry = logEntry
//            modifiedLogEntry["index"] = log.count // Now safely reading log.count inside the queue
//            modifiedLogEntry["date"] = currentDate()
//            
//            // Append the modified log entry inside the barrier-protected block
//            log.append(modifiedLogEntry)
//            saveAsJSON()
//        }
//    }
//    
//    static func deleteLog() {
//        logQueue.async(flags: .barrier) {
//            // Clear the in-memory log
//            log.removeAll()
//            
//            // Delete the log file from the file system
//            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let logFileURL = documentsPath.appendingPathComponent(Self.logFileName)
//            
//            do {
//                if FileManager.default.fileExists(atPath: logFileURL.path) {
//                    try FileManager.default.removeItem(at: logFileURL)
//                    print("\(Self.logPrefix): Deleted log file at: \(logFileURL.absoluteString)")
//                } else {
//                    print("\(Self.logPrefix): Log file does not exist at: \(logFileURL.absoluteString)")
//                }
//            } catch {
//                print("\(Self.logPrefix): Error deleting log file: \(error)")
//            }
//        }
//    }
//}
//
