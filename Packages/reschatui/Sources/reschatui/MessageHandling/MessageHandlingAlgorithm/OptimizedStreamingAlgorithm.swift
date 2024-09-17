//
//  File.swift
//
//
//  Created by Mihaela MJ on 17.09.2024..
//

import Foundation
import Combine
import UIKit

class OptimizedStreamingAlgorithm: MessageHandlingAlgorithm {
    
    func processHistoryMessages(_ receivedMessages: [UIMessage], dataSource: UIMessageDataSource, completion: @escaping (Bool) -> Void) {
        DefaultMessageHandlingAlgorithm().processHistoryMessages(receivedMessages, dataSource: dataSource, completion: completion)
    }
    
    // Process streaming message (partial updates)
    func processStreamingMessage(_ streamingMessage: UIMessage, dataSource: UIMessageDataSource) {
        guard streamingMessage.isBot else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.ensureSectionExists() // Ensure the section exists before any updates
        if streamingMessage.isBotWaiting { print("Bot is waiting.") }
        
        // Locate the current message in the snapshot by message_id
        var currentMessages = snapshot.extractCurrentMessages()
        guard let existingMessageIndex = currentMessages.firstIndex(where: { $0.id == streamingMessage.id }) else {
            return
        }
        
        let existingMessage = currentMessages[existingMessageIndex]
        
        // Ensure that the message part is not out of order (we only want to update with newer parts)
        if streamingMessage.messagePart <= existingMessage.messagePart {
            print("Skipping out-of-order or duplicate message part: \(streamingMessage.messagePart), current part: \(existingMessage.messagePart)")
            return
        }
        
        // Update the message with the new part
        var updatedMessage = existingMessage
        updatedMessage.update(with: streamingMessage)
        
        // If this is the final part, mark it as finished
        if streamingMessage.isFinished { // received message
            updatedMessage.isFinished = true
            print("Final part received for message ID: \(updatedMessage.id)") // onda izbrise message
        }
        /**
         ▿ UIMessage
           - text : ""
           ▿ rawText : Optional<String>
             - some : ""
           - type : reschatui.UIMessageType.bot
           - uuid : 2B193DB7-269A-422F-A2EE-D2DBAC83B26C
           ▿ date : 2024-09-17 01:24:15 +0000
             - timeIntervalSinceReferenceDate : 748229055.0710001
           - timestamp : "2024-09-17T01:24:15.071066+00:00"
           - messagePart : 1
           - messageIndex : 0
           - isFinished : true
         */
        
        // Update the snapshot with the new message part
        snapshot.deleteItems([existingMessage])
        snapshot.insertOrAppendMessage(updatedMessage, at: existingMessageIndex, in: currentMessages)
        
        // Apply the updated snapshot on the main queue
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // Process the final message update (agent_updates_history_item)
    func processUpdatedMessage(_ updatedMessage: UIMessage, dataSource: UIMessageDataSource) {
        var snapshot = dataSource.snapshot()
        
        // Ensure the section exists before any updates
        snapshot.ensureSectionExists()
        
        // Locate the current message in the snapshot by message_id
        var currentMessages = snapshot.extractCurrentMessages()
        guard let existingMessageIndex = currentMessages.firstIndex(where: { $0.id == updatedMessage.id }) else {
            return
        }
        
        let existingMessage = currentMessages[existingMessageIndex]
        
        // Make sure we are updating only after receiving the final message part
        if !updatedMessage.isFinished {
            print("Cannot update message \(updatedMessage.id) because it is not marked as final yet.")
            return
        }
        
        // Finalize the message with the updated content
        var finalMessage = existingMessage
        finalMessage.update(with: updatedMessage)
        
        // Update the snapshot with the finalized message
        snapshot.deleteItems([existingMessage])
        snapshot.insertOrAppendMessage(finalMessage, at: existingMessageIndex, in: currentMessages)
        
        // Apply the final snapshot on the main queue
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
