//
//  ChatViewController+ProxyMessages.swift
//
//
//  Created by Mihaela MJ on 09.09.2024..
//

import Foundation
import Combine
import UIKit
import ResChatUICommon

extension ChatViewController {
    
    func handleConnectionStateChange(_ state: UIConnectionState) {
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
        case .error(_):
            showSocketErrorAlert()
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
        
        print("ATTTT: receivedMessagesAreOlder: \(receivedMessagesAreOlder), scroling: \(receivedMessagesAreOlder ? "to top" : "to bottom")")
        // Use the receivedMessagesAreOlder flag as needed //receivedMessagesAreOlder: true, scroling: to top -- FIXME: -
        receivedMessagesAreOlder ? scrollToTop() : scrollToBottom()
        hideLoadingIndicator()
    }
    
    func processStreamingMessage(_ streamingMessage: UIMessage) {
        guard let manager = self.messageManager else {
            print("Error: message manager is nil")
            return
        }
        
        UILog.shared.logStreamingMessage(streamingMessage)
        
        manager.processStreamingMessage(streamingMessage)
        updateUI(animated: false)
        
        scrollToBottom()
        if streamingMessage.isFinished {
            notifyBotFinishedTyping()
        }
    }
    
    func processUpdatedMessage(_ updatedMessage: UIMessage) {
        guard let manager = self.messageManager else {
            print("Error: message manager is nil")
            return
        }
        UILog.shared.logUpdatedMessage(updatedMessage)
        
        manager.processUpdatedMessage(updatedMessage)
        updateUI(animated: false)
    }
}

// MARK: UI -

extension ChatViewController {
    func updateUI(animated: Bool) {
        
        guard let manager = self.messageManager else { return }
        
        currentSnapshot = UIMessageSnapshot()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(manager.uiMessages, toSection: .main)
        print("updateUI: " + (manager.uiMessages.last?.text ?? "No text"))
        
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
}


