//
//  ResChatSocket+HandleEvents.swift
//
//
//  Created by Mihaela MJ on 31.08.2024..
//

import Foundation
import SocketIO

internal extension ResChatSocket {
    
    // MARK: Connection -
    
    func onConnect(data: [Any], ack: SocketAckEmitter) {
        onConnect(data: data)
    }
    
    func onDisconnect(data: [Any], ack: SocketAckEmitter) {
        onDisconnect(data: data)
    }
    
    func onError(data: [Any], ack: SocketAckEmitter) {
        onError(data: data)
    }
    
    // MARK: History -
    
    func handleReceivedConversations(data: [Any], ack: SocketAckEmitter) { // Conversation
        handleReceivedConversations(data: data)
    }
    
    // MARK: Bot Streaming Message in Parts -
    
    func handleReceivedStreamMessages(data: [Any], ack: SocketAckEmitter) {
        handleReceivedStreamMessages(data: data)
    }
    
    // MARK: Updated Item for History -
    
    func handleReceivedUpdateHistoryItems(data: [Any], ack: SocketAckEmitter) {
        handleReceivedUpdateHistoryItems(data: data)
    }
}

// MARK: Implementations -

internal extension ResChatSocket {
    
    func onConnect(data: [Any]) {
        EventLog.shared.logEvent(name: "onConnect")
        if sendNewConnectedState(.connected) {
            requestInitialHistorySnapshot()
        }
    }
    
    func onDisconnect(data: [Any]) {
        EventLog.shared.logEvent(name: "onDisconnect")
        sendNewConnectedState(.disconnected) // might be deallocated when this is called -
    }
    
    func onError(data: [Any]) {
        let error: Error? = nil // Extract error from data if applicable -
        EventLog.shared.logError(name: "onError", error: error)
        sendUpdateConnectionStateError(error)
    }
}

extension ResChatSocket {

    func handleReceivedConversations(data: [Any]) { // Conversation
        historyIsLoading = false
        do {
            let snapshot = try parseHistory(from: data)
            
            // See if are there more messages to load
            if snapshot.messagesBefore == 0 {
                historyFinishedLoading = true
            }
            
            // Handle conversations
            let newMessages = snapshot.messages.map { SocketMessage(from: $0) }
            
            // Request Welcome Message if needed
            if newMessages.isEmpty {
                print("DBGG: No new messages found, requesting a welcome message.")
                _requestWelcomeMessage()
            }

            let normalizedMessages = normalizeHistoryMessages(newMessages)
            
            EventLog.shared.logEventReceivedConversations(snapshot: snapshot,
                                                          historyFinishedLoading: historyFinishedLoading,
                                                          newMessages: normalizedMessages,
                                                          myMessages: nil)
            
            sendHistoryMessagesIfNeeded(newMessages: normalizedMessages, force: true)
            
            // Remove loading states
            sendNewLoadingState(.loaded)
            sendNewLoadingMoreState(.loadedMore)
            
        } catch let error as ParsingDataError {
            print("Parsing Error: \(error.localizedDescription)")
            EventLog.shared.logReceivedConversationsError(error)
            sendUpdateConnectionStateError(error)
        } catch {
            print("An unexpected error occurred: \(error)")
            EventLog.shared.logReceivedConversationsError(error)
            sendUpdateConnectionStateError(error)
        }
    }
    
    // MARK: Bot Streaming Message in Parts -
    
    func handleReceivedStreamMessages(data: [Any]) {
        do {
            let message = try parseStreamingMessages(from: data)
            EventLog.shared.logEventReceivedStreamMessages(newMessage: message,
                                                           newMessages: nil,
                                                           myMessages: nil)
            
            sendStreamingMessage(message)
        } catch let error as ParsingDataError {
            print("Parsing Error: \(error.localizedDescription)")
            EventLog.shared.logReceivedStreamMessagesError(error)
            sendUpdateConnectionStateError(error)
        } catch {
            print("An unexpected error occurred: \(error)")
            EventLog.shared.logReceivedStreamMessagesError(error)
            sendUpdateConnectionStateError(error)
        }
    }
    
    // MARK: Updated Item for History -
    
    func handleReceivedUpdateHistoryItems(data: [Any]) {
        do {
            let newUpdateItem = try parseUpdateItems(from: data)
            EventLog.shared.logEventReceivedStreamMessages(newMessage: newUpdateItem,
                                                           newMessages: nil,
                                                           myMessages: nil)
            sendUpdatedMessage(newUpdateItem)
            
        } catch let error as ParsingDataError {
            print("Parsing Error: \(error.localizedDescription)")
            EventLog.shared.logReceivedUpdateHistoryItemsError(error)
            sendUpdateConnectionStateError(error)
        } catch {
            print("An unexpected error occurred: \(error)")
            EventLog.shared.logReceivedUpdateHistoryItemsError(error)
            sendUpdateConnectionStateError(error)
        }
        
    }
}


