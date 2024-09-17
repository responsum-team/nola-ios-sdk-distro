//
//  DefaultMessageHandlingAlgorithm.swift
//
//
//  Created by Mihaela MJ on 17.09.2024..
//

import Foundation
import Combine
import UIKit

class DefaultMessageHandlingAlgorithm: MessageHandlingAlgorithm {

    private let messageProcessingQueue = DispatchQueue(label: "com.example.messageProcessingQueue")

    // Process history snapshot with completion handler for receivedMessagesAreOlder
    func processHistoryMessages(_ receivedMessages: [UIMessage], 
                                dataSource: UIMessageDataSource,
                                completion: @escaping (Bool) -> Void) {
        messageProcessingQueue.async {
            var snapshot = dataSource.snapshot()
            // Ensure the section exists before any updates
            snapshot.ensureSectionExists()

            // Determine if received messages are older
            var receivedMessagesAreOlder = false
            let currentMessages = snapshot.extractCurrentMessages()
            if !currentMessages.isEmpty {
                receivedMessagesAreOlder = dataSource.areMessagesOlderThanExisting(receivedMessages: receivedMessages)
            }

            // Delete placeholders if user messages exist
            snapshot.deletePlaceholdersIfUserMessagesExist(receivedMessages: receivedMessages)
            // Clean up any placeholders if necessary
            snapshot.deleteAllBotPlaceholders()

            // Apply the history messages
            snapshot.applyMessagesUpdates(
                receivedMessages: receivedMessages,
                shouldReload: { existingMessage, newMessage in
                    return existingMessage.text != newMessage.text
                }
            )

            // Sort messages by date
            snapshot.sortMessagesByDate()

            // Apply the snapshot back to the data source on the main queue
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: false)
                completion(receivedMessagesAreOlder) // Return the result via completion handler
            }
        }
    }

    // Process streaming message (partial updates)
    func processStreamingMessage(_ streamingMessage: UIMessage, dataSource: UIMessageDataSource) {
        messageProcessingQueue.async {
            guard streamingMessage.isBot else { return }

            var snapshot = dataSource.snapshot()
            snapshot.ensureSectionExists() // Ensure the section exists before any updates
            if streamingMessage.isBotWaiting { print("Bot is waiting.") }

            // Update the message with new streaming parts
            snapshot.updateBotMessageWithNewMessage(streamingMessage)

            // Apply the updated snapshot on the main queue
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }

    // Process the final message update
    func processUpdatedMessage(_ updatedMessage: UIMessage, dataSource: UIMessageDataSource) {
        messageProcessingQueue.async {
            var snapshot = dataSource.snapshot()
            // Ensure the section exists before any updates
            snapshot.ensureSectionExists()

            // Update the finalized message
            snapshot.updateFinalizedMessage(updatedMessage)

            // Apply the snapshot on the main queue
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }
}
