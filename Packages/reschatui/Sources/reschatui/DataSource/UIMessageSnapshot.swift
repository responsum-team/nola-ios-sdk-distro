//
//  UIMessageSnapshot.swift
//  
//
//  Created by Mihaela MJ on 02.09.2024..
//

import UIKit
import ResChatUICommon

public enum ChatSection {
    case main
}

// Custom snapshot type alias
typealias UIMessageSnapshot = NSDiffableDataSourceSnapshot<ChatSection, UIMessage>

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
        
        // Ensure the section exists before deleting items
        if !placeholdersToDelete.isEmpty, 
            sectionIdentifiers.contains(.main) {
            // Ensure that there are rows in the section before attempting deletion
            let rowsInSection = itemIdentifiers(inSection: .main)
            if !rowsInSection.isEmpty {
                // Delete the identified placeholder messages from the snapshot
                deleteItems(placeholdersToDelete)
            }
        }
    }
    
    // Sort messages by date (ascending order)
    // need to add messageIndex to uniquely identify bot message
    mutating func sortMessagesByDate(andIndex: Bool = false) {
        let sortedMessages = sortMessagesByDate(messages: itemIdentifiers, andByIndex: andIndex)

        // Check if there are any items before trying to delete them
        if !itemIdentifiers.isEmpty {
            deleteItems(itemIdentifiers)
        }

        // Ensure the section exists before appending sorted items
        if !sectionIdentifiers.contains(.main) {
            print("Section does not exist, creating section.")
            appendSections([.main])
        }

        // Append sorted messages if there are any
        if !sortedMessages.isEmpty {
            appendItems(sortedMessages, toSection: .main)
        } else {
            print("No sorted messages to append.")
        }
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
