//
//  UIMessageSnapshot.swift
//  
//
//  Created by Mihaela MJ on 02.09.2024..
//

import UIKit

public enum ChatSection {
    case main
}

// Custom snapshot type alias
typealias UIMessageSnapshot = NSDiffableDataSourceSnapshot<ChatSection, UIMessage>

// Extension to add snapshot-specific methods
extension UIMessageSnapshot {
    
    mutating func applyInitialMessages(_ messages: [UIMessage]) {
        appendSections([.main])
        appendItems(messages, toSection: .main)
    }
    
    mutating func clearAllMessages() {
        deleteAllItems()
    }
    
    mutating func updateMessages(_ messages: [UIMessage]) {
        appendItems(messages, toSection: .main)
    }
}


extension UIMessageSnapshot {
    mutating func ensureSectionExists(_ section: ChatSection = .main) {
        if sectionIdentifiers.isEmpty {
           appendSections([section])
        }
    }
    
    func extractCurrentMessages() -> [UIMessage] {
        // Check if the .main section exists
        if sectionIdentifiers.contains(.main) {
            return itemIdentifiers(inSection: .main)
        } else {
            // If the .main section does not exist, return an empty array
            return []
        }
    }
}

// MARK: History Messages Update -

extension UIMessageSnapshot {
    
    /// Deletes placeholder messages if corresponding user messages exist in the received messages
    mutating func deletePlaceholdersIfUserMessagesExist(receivedMessages: [UIMessage]) {
        // Identify placeholder messages that have corresponding user messages
        let placeholdersToDelete = itemIdentifiers.compactMap { existingMessage -> UIMessage? in
            guard case .placeholder(.forUser) = existingMessage.type else {
                return nil // Skip non-placeholder messages
            }
            // Find the corresponding user message with the same text
            if receivedMessages.contains(where: { $0.type == .user && $0.text == existingMessage.text }) {
                return existingMessage // Return the placeholder message to be deleted
            }
            return nil
        }
        
        // Delete the identified placeholder messages from the snapshot
        if !placeholdersToDelete.isEmpty {
            deleteItems(placeholdersToDelete)
        }
    }
    
    mutating func deleteAllBotPlaceholders() {
        let placeholdersToDelete = itemIdentifiers.filter { $0.type == .placeholder(.forBot) }
        if !placeholdersToDelete.isEmpty {
            deleteItems(placeholdersToDelete)
        }
    }
    
    // Update the snapshot with new or reloaded messages
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
    
    mutating func updateMessages(in itemIdentifiers: [UIMessage],
                        with receivedMessages: [UIMessage],
                        shouldReload: (UIMessage, UIMessage) -> Bool) {
        
        let messagesToReload = itemIdentifiers.compactMap { existingMessage -> UIMessage? in
            guard let updatedMessage = receivedMessages.first(where: { $0.timestamp == existingMessage.timestamp }) else {
                return nil
            }
            // If we need to reload, return the updated message; otherwise, return nil
            return shouldReload(existingMessage, updatedMessage) ? updatedMessage : nil
        }
        
        // Perform the reload action by deleting and reinserting the updated items
        if !messagesToReload.isEmpty {
            for message in messagesToReload {
                if let sectionIdentifier = sectionIdentifier(containingItem: message) {
                    deleteItems([message])  // Delete the message
                    appendItems([message], toSection: sectionIdentifier)  // Insert the message back
                }
            }
        }
    }

    
    // Sort messages by date (ascending order)
    // need to add messageIndex to uniquely identify bot message
    mutating func sortMessagesByDate(andIndex: Bool = false) {
        let sortedMessages = sortMessagesByDate(messages: itemIdentifiers, andByIndex: andIndex)
        deleteItems(itemIdentifiers)
        appendItems(sortedMessages, toSection: .main)
    }
    
    func sortMessagesByDate(messages: [UIMessage], andByIndex: Bool = false) -> [UIMessage] {
        return messages.sorted {
            if $0.date != $1.date {
                return $0.date < $1.date  // Sort by date first
            }
            if andByIndex {
                return $0.messageIndex < $1.messageIndex  // Sort by index if the dates are the same and sorting by index is enabled
            }
            return false  // If both date and index are the same, retain the original order
        }
    }
    
    mutating func updateBotMessageWithNewMessage(_ newMessage: UIMessage) {
        guard !newMessage.isBotWaiting else {
            print("DBGGGG: We are waiting, do nothing (displaying animated bot cell).")
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

    /// Helper function to safely insert or append a message at a specific index
    private mutating func insertOrAppendMessage(_ message: UIMessage, at index: Int, in currentMessages: [UIMessage]) {
        if index < currentMessages.count - 1 {
            insertItems([message], beforeItem: currentMessages[index + 1]) // Insert at the same index
        } else {
            appendItems([message], toSection: .main) // Fallback in case of the last item
        }
    }
}
