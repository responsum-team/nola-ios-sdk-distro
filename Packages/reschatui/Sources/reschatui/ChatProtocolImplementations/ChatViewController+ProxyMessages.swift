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
}

extension ChatViewController {
    
    func processHistoryMessages(_ receivedMessages: [UIMessage]) {
        
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

    func processStreamingMessage(_ streamingMessage: UIMessage) {
        messageHandler.processStreamingMessage(streamingMessage, dataSource: dataSource)
        
        scrollToBottom()
        if streamingMessage.isFinished {
            notifyBotFinishedTyping()
        }
    }

    func processUpdatedMessage(_ updatedMessage: UIMessage) {
        messageHandler.processUpdatedMessage(updatedMessage, dataSource: dataSource)
    }
}
