//
//  File.swift
//  ResChatUICommon
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation

/**
 0. Pocetno stanje:
 - [Bot]

 1. Ja saljem poruku:
 - [Bot]
 - P: [User]
 - P: [Bot]
 
 2. Nakon toga dobijem History Snapshot sa 3 poruke:
 - [Bot]
 - [User]
 - [Bot] (...)
 
 3. Streaming Events:
 - [Bot] Part 1
 - [Bot] Part 2
 ...
 - [Bot] Part n, isFinished = true
 
 4. Nakon toga ide Updated Message
 - [Bot] updated
 */

// Streaming
/**
 2. **History**
 - zamjenit `P: [User]` sa `[User]`
 - provjerit `[Bot]` ako je `...`,  ostavit moj loading `P: [Bot]`
 
 3. **Streaming**
 - Zamjenit moj   `P: [Bot]` sa  `[Bot] Part n` opetovano
 
 4. **Updated Message**
 - Zamjenit `[Bot] Part n` sa `[Bot] updated`
 */

class UIMessageManager {
    
    // MARK: Properties -
    
    private var _uiMessages = Set<UIMessage>()
    var uiMessages: Set<UIMessage> { _uiMessages }
    
    func updateMessages(_ messages: [UIMessage]) {
        _uiMessages = Set<UIMessage>(messages)
    }
}

public extension UIMessage {
    
    nonisolated(unsafe) static var current = [UIMessage]()
    
    static func processHistoryMessages(_ receivedMessages: [UIMessage], completion: @escaping (Bool) -> Void) {
        
    }
    
    static func processStreamingMessage(_ streamingMessage: UIMessage) {
        
    }
    
    static func processUpdatedMessage(_ updatedMessage: UIMessage) {
        
    }
    
}

