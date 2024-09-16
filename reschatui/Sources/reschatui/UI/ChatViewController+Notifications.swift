//
//  File.swift
//  
//
//  Created by Mihaela MJ on 13.09.2024..
//

import Foundation

extension Notification.Name {
    static let botStartedTyping = Notification.Name("botStartedTyping")
    static let botFinishedTyping = Notification.Name("botFinishedTyping")
}

internal extension ChatViewController {
    func subscribeToNotifications() {
        // Observe when bot starts and finishes typing
        NotificationCenter.default.addObserver(self, selector: #selector(handleBotStartedTyping), name: .botStartedTyping, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleBotFinishedTyping), name: .botFinishedTyping, object: nil)
    }
    
    @objc func handleBotStartedTyping() {
        // Disable input when the bot starts typing
        setTypingState(isTyping: true)
    }

    @objc func handleBotFinishedTyping() {
        // Re-enable input when the bot finishes typing
        setTypingState(isTyping: false)
    }
    
    func setTypingState(isTyping: Bool) {
        isTyping ? print("DBGGG: Bot started typing...") : print("DBGGG: Bot finished typing...") 
    }
}


internal extension ChatViewController {
    
    func notifyBotStartedTyping() {
        NotificationCenter.default.post(name: .botStartedTyping, object: nil)
    }

    func notifyBotFinishedTyping() {
        NotificationCenter.default.post(name: .botFinishedTyping, object: nil)
    }
}
