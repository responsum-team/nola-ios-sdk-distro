//
//  File.swift
//  
//
//  Created by Mihaela MJ on 17.09.2024..
//

import Foundation
import Combine
import UIKit

extension UIMessageSnapshot {
    
    // Apply message updates with reload conditions
    mutating func applyMessagesUpdates(receivedMessages: [UIMessage], shouldReload: (UIMessage, UIMessage) -> Bool) {
        let existingMessageTimestamps = Set(itemIdentifiers.map { $0.timestamp })

        // Identify new messages to append (not already in the snapshot)
        let messagesToAppend = receivedMessages.filter { !existingMessageTimestamps.contains($0.timestamp) }

        updateMessages(in: itemIdentifiers, with: receivedMessages, shouldReload: shouldReload)

        // Append new messages
        if !messagesToAppend.isEmpty {
            appendItems(messagesToAppend, toSection: .main)
        }
    }
    
    // Update existing messages in the snapshot based on the reload condition
    mutating func updateMessages(in itemIdentifiers: [UIMessage],
                                 with receivedMessages: [UIMessage],
                                 shouldReload: (UIMessage, UIMessage) -> Bool) {
        let messagesToReload = itemIdentifiers.compactMap { existingMessage -> UIMessage? in
            guard let updatedMessage = receivedMessages.first(where: { $0.timestamp == existingMessage.timestamp }) else {
                return nil
            }
            // If we need to reload, return the updated message
            return shouldReload(existingMessage, updatedMessage) ? updatedMessage : nil
        }

        // Perform the reload by deleting and reinserting the updated items
        if !messagesToReload.isEmpty {
            for message in messagesToReload {
                if let sectionIdentifier = sectionIdentifier(containingItem: message) {
                    deleteItems([message])  // Delete the old message
                    appendItems([message], toSection: sectionIdentifier)  // Reinsert the updated message
                }
            }
        }
    }
    
    // Update bot message with the new streaming message
    mutating func updateBotMessageWithNewMessage(_ newMessage: UIMessage) {
        guard !newMessage.isBotWaiting else {
            print("DBGGGG: Bot is waiting, do nothing (displaying animated bot cell).")
            return
        }

        var currentMessages = extractCurrentMessages()

        // Locate the existing bot message
        guard let existingMessageIndex = currentMessages.firstIndex(where: { $0.timestamp == newMessage.timestamp && $0.isBot }) else { return }
        let existingMessage = currentMessages[existingMessageIndex]

        deleteAllBotPlaceholders()

        var updatedMessage = existingMessage
        updatedMessage.update(with: newMessage)

        deleteItems([existingMessage])
        insertOrAppendMessage(updatedMessage, at: existingMessageIndex, in: currentMessages)
    }
    
    // Update and finalize the message in the snapshot
    mutating func updateFinalizedMessage(_ newMessage: UIMessage) {
        var currentMessages = extractCurrentMessages()
        
        // Locate the existing message
        guard let existingMessageIndex = currentMessages.firstIndex(where: { $0.id == newMessage.id }) else {
            // If the message doesn't exist, append it
            appendItems([newMessage], toSection: .main)
            return
        }
        
        let existingMessage = currentMessages[existingMessageIndex]
        
        // Prevent further updates if the message is already finalized
        if existingMessage.isFinished {
            print("DBGG: Message \(existingMessage.id) is already finalized, no updates allowed.")
            return
        }
        
        // Update the existing message with the final message content
        var updatedMessage = existingMessage
        updatedMessage.update(with: newMessage)
        updatedMessage.isFinished = true // Mark the message as finalized
        
        deleteItems([existingMessage])
        insertOrAppendMessage(updatedMessage, at: existingMessageIndex, in: currentMessages)
    }
    
    // Utility function to extract current messages from the snapshot
    func extractCurrentMessages() -> [UIMessage] {
        return itemIdentifiers
    }
    
    // Utility function to insert or append a message at a specific index
    mutating func insertOrAppendMessage(_ message: UIMessage, at index: Int, in currentMessages: [UIMessage]) {
        if index < currentMessages.count - 1 {
            insertItems([message], beforeItem: currentMessages[index + 1]) // Insert at the same index
        } else {
            appendItems([message], toSection: .main) // Fallback in case it's the last item
        }
    }
    
    // Delete all bot placeholders
    mutating func deleteAllBotPlaceholders() {
        let botPlaceholders = itemIdentifiers.filter { $0.isBot && $0.isPlaceholder }
        deleteItems(botPlaceholders)
    }
}
