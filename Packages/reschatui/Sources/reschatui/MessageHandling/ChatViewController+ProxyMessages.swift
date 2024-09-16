//
//  ChatViewController+ProxyMessages.swift
//
//
//  Created by Mihaela MJ on 09.09.2024..
//

import Foundation
import Combine
import UIKit

extension ChatViewController {
    
    func handleConnectionStateChange(_ state: UIConnectionState) {
        UILog.shared.logStateAction(name: "handleConnectionStateChange", state: state.toString())
        
        switch state {
        case .connected:
            break
        case .disconnected:
            break
        case .loading:
            // Show a loading indicator while the connection is being established
            showLoadingIndicator()
        case .loaded:
            // Hide any loading indicators and enable full interaction
            hideLoadingIndicator()
        case .error(let error):
            showSocketErrorAlert()
        case .loadingMore:
            addLoadingMessage()
        case .loadedMore:
            removeLoadingMessage()
        }
    }
    
    private func describeMessages(_ messages: [UIMessage], title: String) {
        func niceDateFrom(_ date: Date?) -> String {
            guard let date = date else { return "" }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm:ss"
            return dateFormatter.string(from: date)
        }
        print("DBGG: \(title) messages: \(messages.count) are ranging from \(niceDateFrom(messages.first?.date)) to \(niceDateFrom(messages.last?.date))")
    }
    
    func handleMessages(_ receivedMessages: [UIMessage]) {// agent_sends_history_snapshot
        
        if receivedMessages.isEmpty && didRequestToClearChat {
            didRequestToClearChat = false
            clear()
            hideLoadingIndicator()
            return
        }
        
        showLoadingIndicator()

        func shouldReload(existingMessage: UIMessage, newMessage: UIMessage) -> Bool {
            return existingMessage.text != newMessage.text
        }

        var snapshot = dataSource.snapshot()
        let currentMessages = snapshot.extractCurrentMessages()

//        describeMessages(currentMessages, title: "Existing")
//        describeMessages(receivedMessages, title: "Received")
        
        // Log the current state
        UILog.shared.logHandleMessages(
            newMessages: receivedMessages,
            myMessages: currentMessages,
            toReload: nil,  // Handled in the snapshot now
            toAppend: nil,  // Handled in the snapshot now
            toRemove: nil,
            finalResult: nil
        )

        // Ensure the section exists before updating items
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([.main])
        }

        // Determine whether the received messages are older
        let receivedMessagesAreOlder = !currentMessages.isEmpty && dataSource.areMessagesOlderThanExisting(receivedMessages: receivedMessages)
//        print("DBGG: Handling received messages: \(receivedMessages.count) new (\(receivedMessagesAreOlder ? "older" : "newer") messages.")

        // Delete placeholders if user messages exist
        snapshot.deletePlaceholdersIfUserMessagesExist(receivedMessages: receivedMessages)
        // Delete bot placeholders
        snapshot.deleteAllBotPlaceholders()
        
        // Update the snapshot with the new or updated messages
        snapshot.applyMessagesUpdates( // Crash here:
            receivedMessages: receivedMessages, 
            shouldReload: shouldReload
        )

        // Ensure that messages are sorted by date (ascending order) in the snapshot
        snapshot.sortMessagesByDate()

        // Apply the updated snapshot
        dataSource.apply(snapshot, animatingDifferences: false)

        // Log the updated messages
        let updatedMessages = snapshot.extractCurrentMessages()
        if updatedMessages.isEmpty {
            print("DBGG: No messages available in the snapshot.")
        } else {
            describeMessages(updatedMessages, title: "Updated")
        }

        // Log the current state
        UILog.shared.logHandleMessages(
            newMessages: receivedMessages,
            myMessages: currentMessages,
            toReload: nil,  // Handled in the snapshot now
            toAppend: nil,  // Handled in the snapshot now
            toRemove: nil,
            finalResult: updatedMessages
        )

        // Optionally scroll based on the message type
        receivedMessagesAreOlder ? scrollToTop() : scrollToBottom()
        
        hideLoadingIndicator()
    }
    
    func handleUpdatedMessage(_ updatedMessage: UIMessage) { // agent_updates_history_item
        UILog.shared.logUpdatedMessage(updatedMessage)
        handleStreamingMessage(updatedMessage)
    }
    
    func handleStreamingMessage(_ streamingMessage: UIMessage) { // agent_streams_message
        guard streamingMessage.isBot else { return }
        UILog.shared.logStreamingMessage(streamingMessage)

        var snapshot = dataSource.snapshot()
        snapshot.updateBotMessageWithNewMessage(streamingMessage)
        
//        print("DBGGGG: Applying snapshot with \(snapshot.numberOfItems) items")
        dataSource.apply(snapshot, animatingDifferences: false)
        scrollToBottom()
        
        if streamingMessage.isFinished {
            notifyBotFinishedTyping()
        }
    }
}

