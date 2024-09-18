//
//  File.swift
//  ResChatUICommon
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation

/**
 ```
 func updateUI(animated: Bool) {
     guard let controller = self.wifiManager else { return }
     
     let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }
     
     currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
     
     currentSnapshot.appendSections([.config])
     currentSnapshot.appendItems(configItems, toSection: .config)
     
     if controller.wifiEnabled {
         let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
         let networkItems = sortedNetworks.map { Item(network: $0) }
         currentSnapshot.appendSections([.networks])
         currentSnapshot.appendItems(networkItems, toSection: .networks)
     }
 
     dataSource.apply(currentSnapshot, animatingDifferences: animated)
     let items = currentSnapshot.itemIdentifiers.map { $0.title }
 }
 */

/**
 ```
    self.wifiManager = WiFiManager { [weak self] (controller: WiFiManager) in
     guard let self = self else { return }
     self.updateUI(animated: true)
 }
 */

/**


 */

/**
 0. Pocetno stanje:
 - [Bot]

 1. Ja saljem poruku:
 - [Bot]
 - P: [User]
 - P: [Bot]
 
 2. Nakon toga dobijem History Snapshot sa 3 poruke:
 - [Bot]
 - [User]
 - [Bot] (...)
 
 3. Streaming Events:
 - [Bot] Part 1
 - [Bot] Part 2
 ...
 - [Bot] Part n, isFinished = true
 
 4. Nakon toga ide Updated Message
 - [Bot] updated
 */

// Streaming
/**
 2. **History**
 - zamjenit `P: [User]` sa `[User]`
 - provjerit `[Bot]` ako je `...`,  ostavit moj loading `P: [Bot]`
 
 3. **Streaming**
 - Zamjenit moj   `P: [Bot]` sa  `[Bot] Part n` opetovano
 
 4. **Updated Message**
 - Zamjenit `[Bot] Part n` sa `[Bot] updated`
 */

public class UIMessageManager {
    
    public typealias UpdateHandler = (UIMessageManager) -> Void
    
    private let updateHandler: UpdateHandler
    
    // MARK: Properties -
    
    private var _uiMessages = [UIMessage]()
    public var uiMessages: [UIMessage] { _uiMessages }
    
    
    // MARK: Init -
    
    public init(updateHandler: @escaping UpdateHandler) {
        self.updateHandler = updateHandler
    }
}


private extension UIMessageManager {
    
    func updateMessages(_ messages: [UIMessage]) {
        _uiMessages = messages
    }

    static func messagesAreOlder(_ messages: [UIMessage], thanOtherMessages: [UIMessage]) -> Bool {
        guard let earliestMessage = messages.min(by: { $0.date < $1.date }),
              let earliestOtherMessage = thanOtherMessages.min(by: { $0.date < $1.date }) else {
            // Fallback: assume messages are older if we can't compare
            return true
        }
        return earliestMessage.date < earliestOtherMessage.date
    }
    
    static func sortMessagesByDateAscending(messages: [UIMessage], andByIndex: Bool = false) -> [UIMessage] {
        return messages.sorted {
            if $0.date != $1.date {
                return $0.date < $1.date  // Sort by date first (ascending)
            }
            if andByIndex {
                return $0.messageIndex < $1.messageIndex  // Sort by index if the dates are the same and sorting by index is enabled
            }
            return false  // If both date and index are the same, retain the original order
        }
    }

    static func replaceUserPlaceholders(
        in messages: [UIMessage],
        with newMessages: [UIMessage],
        keepPlaceholderIfNoMatch: Bool = false
    ) -> [UIMessage] {
        return messages.compactMap { existingMessage -> UIMessage? in
            // Only proceed if the message is a placeholder for a user
            guard case .placeholder(.forUser) = existingMessage.type else {
                return existingMessage // Return non-placeholder messages as is
            }
            
            // Find the corresponding user message in newMessages with the same text
            if let matchingUserMessage = newMessages.first(where: { $0.type == .user && $0.text == existingMessage.text }) {
                return matchingUserMessage // Replace the placeholder with the user message
            }
            
            // If no match, return the placeholder or nil depending on the flag
            return keepPlaceholderIfNoMatch ? existingMessage : nil
        }
    }
    
    static func replaceBotPlaceholders(
        in messages: [UIMessage],
        with newMessages: [UIMessage],
        keepPlaceholderIfNoMatch: Bool = false
    ) -> [UIMessage] {
        return messages.compactMap { existingMessage -> UIMessage? in
            // Only work with bot placeholders
            guard case .placeholder(.forBot) = existingMessage.type else {
                return existingMessage // Return non-placeholder messages as is
            }
            
            // Find the last bot message from newMessages that is waiting and not already in current messages
            if let matchingBotMessage = newMessages.last(where: {
                $0.type == .bot &&
                $0.isBotWaiting &&
                !Self.messages(messages, containMessage: $0)
            }) {
                return matchingBotMessage // Replace the placeholder with the matching bot message
            }
            
            // If no match, return the placeholder or nil based on keepPlaceholderIfNoMatch
            return keepPlaceholderIfNoMatch ? existingMessage : nil
        }
    }
    
    static func findMessage(_ message: UIMessage, in messages: [UIMessage]) -> UIMessage? {
        return messages.first(where:  { $0.id == message.id } )
    }
    
    static func messages(_ messages: [UIMessage], containMessage: UIMessage) -> Bool {
        return messages.contains { candidate in
            containMessage.id == candidate.id
        }
    }
    
    static func mergeArraysRemovingDuplicates(_ array1: [UIMessage], with array2: [UIMessage]) -> [UIMessage] {
        // Create a set from both arrays to automatically remove duplicates
        let mergedSet = Set(array1).union(Set(array2))
        
        // Convert the set back to an array and return
        return Array(mergedSet)
    }
}

public extension UIMessageManager {
    func receivedMessagesAreOlder(_ receivedMessages: [UIMessage]) -> Bool {
        Self.messagesAreOlder(receivedMessages, thanOtherMessages: _uiMessages)
    }
}

public extension UIMessageManager {
    
    @MainActor
    func processSendMessageWith(text: String) {
        
        /**
         didTapSendUserMessageSubject.send(text)

         addUserPlaceholderMessage(message)
         dismissKeyboard()
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             self.addBotPlaceholderMessage("")
         }
         */
        var currentMessages = _uiMessages
        
        currentMessages = Self.sortMessagesByDateAscending(messages: currentMessages)
        let newUserMessage = UIMessage.newPlaceholderUserMessage(text)
        currentMessages.append(newUserMessage)
        updateMessages(currentMessages)
//        updateHandler(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            Task { @MainActor in
                let newBotMessage = UIMessage.newPlaceholderBotMessage("")
                currentMessages.append(newUserMessage)
                updateMessages(currentMessages)
//                updateHandler(self)
            }
        }
        
    }
    
    func processHistoryMessages(_ receivedMessages: [UIMessage]) {
        var currentMessages = _uiMessages
        
        // handle "P: [User]" case -> replace my `P: [User]` with `[User]`, or delete my user placeholder
        currentMessages = Self.replaceUserPlaceholders(in: currentMessages, with: receivedMessages)
        
        // handle "P [Bot]" case -> replace my `P: [Bot]` with the received (probably Dummy "...") bot, or delete my bot placeholder
        currentMessages = Self.replaceBotPlaceholders(in: currentMessages, with: receivedMessages)
        
        // merge both arrays
        let mergedMessages =  Array(Set(currentMessages + receivedMessages))
        
        // sort messages by date
        currentMessages = Self.sortMessagesByDateAscending(messages: mergedMessages)
        
        updateMessages(currentMessages)
//        updateHandler(self)
    }
    
    func processStreamingMessage(_ streamingMessage: UIMessage) {
        if !streamingMessage.isBot {
            print("Error: Received a streaming message that is not a bot!.")
        }
        var currentMessages = _uiMessages
        
        // delete placeholders if needed
        currentMessages = currentMessages.filter { !$0.isPlaceholder }
        
        // update Bot with Bot/part
        currentMessages = currentMessages.map {
            ($0.id == streamingMessage.id
             && streamingMessage.messagePart > $0.messagePart
             && $0.isBot == true && streamingMessage.isBot == true)
            ? streamingMessage : $0
        }
        
        updateMessages(currentMessages)
//        updateHandler(self)
    }
    
    func processUpdatedMessage(_ updatedMessage: UIMessage) {
        var currentMessages = _uiMessages
        
        // delete placeholders if needed
        currentMessages = currentMessages.filter { !$0.isPlaceholder }

        // Just update message in question, whether bot or user, but must be of the same type
        currentMessages = currentMessages.map {
            ($0.id == updatedMessage.id
             && updatedMessage.messagePart > $0.messagePart
             && $0.isBot == updatedMessage.isBot)
            ? updatedMessage : $0
        }
        
        updateMessages(currentMessages)
//        updateHandler(self)
    }
}


