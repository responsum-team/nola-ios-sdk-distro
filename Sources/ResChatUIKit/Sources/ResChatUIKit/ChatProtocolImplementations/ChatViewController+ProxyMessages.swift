//
//  ChatViewController+ProxyMessages.swift
//
//
//  Created by Mihaela MJ on 09.09.2024..
//

import Foundation
import Combine
#if os(iOS)
import UIKit
import ResChatUICommon

extension ChatViewController {
    
    func handleConnectionStateChange(_ state: UIConnectionState) {
        switch state {
        case .connected:
            hasReceivedConnectionState = true
            isSocketConnected = true
            updateDisconnectedIndicator()
        case .disconnected:
            isSocketConnected = false
            // Only show the indicator if we've previously connected.
            // The initial .disconnected from CurrentValueSubject replay is ignored.
            updateDisconnectedIndicator(reconnecting: false)
        case .loading:
            // Show a loading indicator while the connection is being established
            showLoadingIndicator()
        case .loaded:
            // Hide any loading indicators and enable full interaction
            hideLoadingIndicator()
            updateDisconnectedIndicator()
        case .error(_):
            hasReceivedConnectionState = true
            isSocketConnected = false
            // Error = socket is trying to reconnect automatically
            updateDisconnectedIndicator(reconnecting: true)
        case .loadingMore:
            addLoadingMessage()
        case .loadedMore:
            removeLoadingMessage()
        }
    }
}

extension ChatViewController {

    func processHistoryMessages(_ receivedMessages: [UIMessage]) {
        guard let manager = self.messageManager else {
            print("Error: message manager is nil")
            return
        }
        
        UILog.shared.logHistoryMessages(receivedMessages: receivedMessages,
                                        currentMessages: dataSource.snapshot().itemIdentifiers)
        
        // Check for `clear chat` -
        if receivedMessages.isEmpty && didRequestToClearChat {
            didRequestToClearChat = false
            manager.clearMessages()
            updateUI(animated: true)
            hideLoadingIndicator()
            return
        }
        
        showLoadingIndicator()
        
        // Determine if received messages are older
        let receivedMessagesAreOlder = manager.receivedMessagesAreOlder(receivedMessages)
        
        manager.processHistoryMessages(receivedMessages)
        updateUI(animated: false)

        receivedMessagesAreOlder ? scrollToTop() : scrollToBottom()
        hideLoadingIndicator()
    }
    
    func processStreamingMessage(_ streamingMessage: UIMessage) {
        guard let manager = self.messageManager else {
            print("Error: message manager is nil")
            return
        }
        
        guard !streamingMessage.isDefaultEmptyMessage else {
            print("Skipping empty subscription messages!")
            return
        }
        
        UILog.shared.logStreamingMessage(streamingMessage)
        
        let messageCountBefore = manager.uiMessages.count
        manager.processStreamingMessage(streamingMessage)
        let messageCountAfter = manager.uiMessages.count
        
        let isNewRow = messageCountAfter != messageCountBefore
        
        if isNewRow {
            // A new message row was added (first chunk or new message) —
            // we need a full snapshot apply so the table view inserts the row.
            UIView.performWithoutAnimation {
                updateUI(animated: false)
                tableView.layoutIfNeeded()
            }
        } else {
            // Existing message updated with new text — update the visible cell
            // directly to avoid the full snapshot rebuild which causes screen flashing.
            updateStreamingCellInPlace(with: streamingMessage)
        }

        if currentBotID == nil {
            currentBotID = streamingMessage.id
        } else {
            updateBotIDWithMessage(streamingMessage)
        }
        
        scrollToBottom()
    }
    
    func processUpdatedMessage(_ updatedMessage: UIMessage) {
        guard let manager = self.messageManager else {
            print("Error: message manager is nil")
            return
        }
        UILog.shared.logUpdatedMessage(updatedMessage)
        
        manager.processUpdatedMessage(updatedMessage)
        
        updateBotIDWithMessage(updatedMessage)
        
        updateUI(animated: false)
    }
}

// MARK: Plumbing -

private extension ChatViewController {
    func updateBotIDWithMessage(_ botMessage: UIMessage) {
        guard botMessage.type == .bot,
                botMessage.isFinished,
                let botID = currentBotID else { return }
        guard botMessage.id == botID else { return }
        currentBotID = nil
    }

    /// Updates the streaming bot cell directly without rebuilding the snapshot.
    /// This avoids the full diffable data source apply cycle (remove + insert)
    /// which causes the screen to flash on every streaming chunk.
    func updateStreamingCellInPlace(with message: UIMessage) {
        // Find the visible cell that corresponds to this streaming message
        for cell in tableView.visibleCells {
            guard let botCell = cell as? ChatBotMessageCell,
                  let indexPath = tableView.indexPath(for: cell),
                  let existingMessage = dataSource.itemIdentifier(for: indexPath),
                  existingMessage.id == message.id else { continue }

            // Reconfigure the cell with the updated message
            botCell.configure(with: message)

            // Tell the table view to recalculate this cell's height
            // without reloading (which would cause a flash).
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return
        }

        // Cell not visible — fall back to full snapshot apply
        UIView.performWithoutAnimation {
            updateUI(animated: false)
            tableView.layoutIfNeeded()
        }
    }
}

// MARK: UI -

extension ChatViewController {
    func updateUI(animated: Bool) {
        
        guard let manager = self.messageManager else { return }
        
        messagesArrived()

        // Deduplicate by id (timestamp), keeping the last occurrence (most up-to-date)
        // This prevents NSDiffableDataSourceSnapshot from crashing on duplicate identifiers
        var seenIDs = Set<String>()
        var deduplicated = [UIMessage]()
        for message in manager.uiMessages.reversed() {
            if seenIDs.insert(message.id).inserted {
                deduplicated.append(message)
            }
        }
        deduplicated.reverse()
        
        currentSnapshot = UIMessageSnapshot()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(deduplicated, toSection: .main)
//        print("updateUI: " + (manager.uiMessages.last?.text ?? "No text"))
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}

// MARK: Send UI Message (Placeholders)  -

internal extension ChatViewController {
    
    func sendUIMessage(_ message: String) {
        
        // Don't add any placeholders if we already have placeholders in the snapshot
        guard !dataSource.snapshot().hasUserOrBotPlaceholders() else {
            return
        }
        
        // add placeholder message
        addUserPlaceholderMessage(message)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.addBotPlaceholderMessage("")
        }
    }
    
    func sendUIText(with message: String) {
        // Add user message immediately
        addUserChatText(message)
        // Add a demo chatbot response with a delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.addChatbotChatText("This is a demo response from the chatbot 🤖? Let me see 👀 what I have filed under: `\(message)`")
        }
    }
}
#endif
