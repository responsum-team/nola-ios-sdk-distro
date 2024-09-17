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
}
