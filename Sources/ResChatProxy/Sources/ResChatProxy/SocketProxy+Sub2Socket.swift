//
//  SocketToUIProxy+SocketEvent.swift
//  
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import Combine

// MARK: Socket Subscriptions -

internal extension SocketProxy {
    
    // Receiving messages from socket -
    func setupConnectionStateSubscription() {
        socketProviding?.didChangeConnectionStatePublisher
            .receive(on: DispatchQueue.main)  // Ensure that UI updates happen on the main thread
            .sink { [weak self] socketState in
                guard let self = self else { return }
                let state = socketState.toConnectionState
                self._didChangeConnectionStatePublisher.send(state)
            }
            .store(in: &cancellables)
    }
    
    func setupMessagesSubscription() {
        socketProviding?.didReceiveHistoryMessagesPublisher
            .subscribe(on: DispatchQueue.global(qos: .background)) // Process messages in the background
            .receive(on: DispatchQueue.main)
            .sink { [weak self] socketMessages in
                guard let self = self else { return }
                let messages = socketMessages.map { $0.toMessage() }
                self._didReceiveMessagesPublisher.send(messages)
            }
            .store(in: &cancellables)
    }
    
    func setupStreamingMessageBufferedSubscription() {
        socketProviding?.didReceiveStreamingMessagePublisher
            .subscribe(on: DispatchQueue.global(qos: .background)) // Process messages in the background
            .receive(on: DispatchQueue.main)  // Ensure UI updates happen on the main thread
            .collect(.byTimeOrCount(DispatchQueue.main,
                                    .milliseconds(MessageBufferingConfig.myMessagesBufferInterval),
                                    MessageBufferingConfig.myMessagesBufferMessageCount))  // Buffer messages based on time or count
            .sink { [weak self] bufferedMessages in
                guard let self = self else { return }

                // Group by message ID and forward the latest part for each unique message
                // This ensures we don't drop updates for different messages within the same buffer window
                var latestByID = [String: Int]()
                for (index, msg) in bufferedMessages.enumerated() {
                    latestByID[msg.messageTimestamp] = index
                }
                for (_, index) in latestByID {
                    let message = bufferedMessages[index].toMessage()
                    self._didReceiveStreamingMessagePublisher.send(message)
                }
            }
            .store(in: &cancellables)
    }
    
    func setupUpdatedMessageSubscription() {
        socketProviding?.didUpdateMessagePublisher
            .subscribe(on: DispatchQueue.global(qos: .background)) // Process messages in the background
            .receive(on: DispatchQueue.main)  // Ensure that UI updates happen on the main thread
            .sink { [weak self] socketMessage in
                guard let self = self else { return }
                let message = socketMessage.toMessage()
                self._didReceiveUpdatedMessagePublisher.send(message)
            }
            .store(in: &cancellables)
    }
}
