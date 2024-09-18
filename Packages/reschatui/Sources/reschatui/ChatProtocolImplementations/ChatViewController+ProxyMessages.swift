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
        case .error(let error):
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
        
        UILog.shared.logHistoryMessages(receivedMessages: receivedMessages, currentMessages: dataSource.snapshot().itemIdentifiers)
        
        // Check for `clear chat` -
        if receivedMessages.isEmpty && didRequestToClearChat {
            didRequestToClearChat = false
            clear()
            hideLoadingIndicator()
            return
        }
        
        showLoadingIndicator()
        
        var receivedMessagesAreOlder = false

        
        // Use the receivedMessagesAreOlder flag as needed
        receivedMessagesAreOlder ? scrollToTop() : scrollToBottom()
        
        hideLoadingIndicator()
    }
    
    func processStreamingMessage(_ streamingMessage: UIMessage) {
        

        
        scrollToBottom()
        if streamingMessage.isFinished {
            notifyBotFinishedTyping()
        }
    }
    
    func processUpdatedMessage(_ updatedMessage: UIMessage) {

    }
}

extension ChatViewController {
    func updateUI(animated: Bool) {
        // TODO: -
    }
}

extension ChatViewController {
    
    func processHistoryMessagesOld(_ receivedMessages: [UIMessage]) {
        
        UILog.shared.logHistoryMessages(receivedMessages: receivedMessages, currentMessages: dataSource.snapshot().itemIdentifiers)
        
        // Check for `clear chat` -
        if receivedMessages.isEmpty && didRequestToClearChat {
            didRequestToClearChat = false
            clear()
            hideLoadingIndicator()
            return
        }
        
        showLoadingIndicator()
        
        var receivedMessagesAreOlder = false
        messageHandler.processHistoryMessages(receivedMessages,
                                              dataSource: dataSource,
                                              completion: { older in receivedMessagesAreOlder = older })
        
        // Use the receivedMessagesAreOlder flag as needed
        receivedMessagesAreOlder ? scrollToTop() : scrollToBottom()
        
        hideLoadingIndicator()
    }
    
    func processStreamingMessageOld(_ streamingMessage: UIMessage) {
        
        messageHandler.processStreamingMessage(streamingMessage, dataSource: dataSource)
        
        scrollToBottom()
        if streamingMessage.isFinished {
            notifyBotFinishedTyping()
        }
    }
    
    func processUpdatedMessageOld(_ updatedMessage: UIMessage) {
        messageHandler.processUpdatedMessage(updatedMessage, dataSource: dataSource)
    }
}
