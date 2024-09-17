//
//  File.swift
//  ResChatUICommon
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation

public extension UIMessage {
    
    nonisolated(unsafe) static var current = [UIMessage]()
    
    static func processHistoryMessages(_ receivedMessages: [UIMessage], completion: @escaping (Bool) -> Void) {
        
    }
    
    static func processStreamingMessage(_ streamingMessage: UIMessage) {
        
    }
    
    static func processUpdatedMessage(_ updatedMessage: UIMessage) {
        
    }
    
}
