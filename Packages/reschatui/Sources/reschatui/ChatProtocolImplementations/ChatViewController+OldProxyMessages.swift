//
//  ChatViewController+OldProxyMessages.swift
//  reschatui
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation
import Combine
import UIKit
import ResChatUICommon

extension ChatViewController {
    
    func processHistoryMessagesOld(_ receivedMessages: [UIMessage]) {
        
        UILog.shared.logHistoryMessages(receivedMessages: receivedMessages, currentMessages: dataSource.snapshot().itemIdentifiers)
        
        // Check for `clear chat` -
        if receivedMessages.isEmpty && didRequestToClearChat {
            didRequestToClearChat = false
//            clear()
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
