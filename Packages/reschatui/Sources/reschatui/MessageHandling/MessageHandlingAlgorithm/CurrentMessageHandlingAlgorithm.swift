//
//  File.swift
//  
//
//  Created by Mihaela MJ on 17.09.2024..
//

import Foundation
import Combine
import UIKit

class CurrentMessageHandlingAlgorithm: MessageHandlingAlgorithm {
    
    func processHistoryMessages(_ receivedMessages: [UIMessage], 
                                dataSource: UIMessageDataSource,
                                completion: @escaping (Bool) -> Void) {
        
        var snapshot = dataSource.snapshot()
        snapshot.ensureSectionExists()  // Ensure the section exists before any updates
        let currentMessages = snapshot.extractCurrentMessages()
        
        // Determine whether the received messages are older
        var receivedMessagesAreOlder = !currentMessages.isEmpty && dataSource.areMessagesOlderThanExisting(receivedMessages: receivedMessages)
        
        // Delete placeholders if user messages exist
        snapshot.deletePlaceholdersIfUserMessagesExist(receivedMessages: receivedMessages)
        // Delete bot placeholders
        snapshot.deleteAllBotPlaceholders()
        
        // Update the snapshot with the new or updated messages
        snapshot.applyMessagesUpdates(receivedMessages: receivedMessages, shouldReload: { existingMessage, newMessage in
            return existingMessage.text != newMessage.text
        })

        snapshot.sortMessagesByDate()

        dataSource.apply(snapshot, animatingDifferences: false)
        completion(receivedMessagesAreOlder)
    }

    func processStreamingMessage(_ streamingMessage: UIMessage, dataSource: UIMessageDataSource) {
        guard streamingMessage.isBot else { return }

        var snapshot = dataSource.snapshot()
        snapshot.ensureSectionExists() // Ensure the section exists before any updates
        if streamingMessage.isBotWaiting { print("Bot is waiting.") }
        
        snapshot.updateBotMessageWithNewMessage(streamingMessage)

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func processUpdatedMessage(_ updatedMessage: UIMessage, dataSource: UIMessageDataSource) {
       processStreamingMessage(updatedMessage, dataSource: dataSource)
    }
}
