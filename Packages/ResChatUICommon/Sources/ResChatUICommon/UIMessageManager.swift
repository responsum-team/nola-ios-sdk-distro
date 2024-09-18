//
//  UIMessageManager.swift
//  ResChatUICommon
//
//  Created by Mihaela MJ on 18.09.2024..
//

import Foundation


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
    
    // MARK: Private -
    
    private func updateMessages(_ messages: [UIMessage]) {
        _uiMessages = messages
    }
}

// MARK: Process -

public extension UIMessageManager {
    
    @MainActor
    func processSendMessageWith(text: String) {
        
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
                currentMessages.append(newBotMessage)
                updateMessages(currentMessages)
//                updateHandler(self)
            }
        }
    }
    
    func clearMessages() {
        _uiMessages.removeAll()
        updateMessages(_uiMessages)
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
             && $0.isBot == updatedMessage.isBot)
            ? updatedMessage : $0
        }
        
        updateMessages(currentMessages)
//        updateHandler(self)
    }
}


