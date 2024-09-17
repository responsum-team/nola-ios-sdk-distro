//
//  MessageProviding+Socket.swift
//  ResChatUIApp
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import reschatSocket
import ResChatProtocols

extension reschatSocket.SocketMessage: @retroactive MessageProviding {
    
    public var messageOrigin: ResChatProtocols.MessageOrigin {
        socketSource.toMessageOrigin
    }
    
    public var timestamp: String {
        messageTimestamp
    }
    
    public var messagePart: Int {
        messagePartNumber
    }
    
    public var isFinished: Bool {
        isMessageFinished
    }
    
    public var isFromBot: Bool {
        isBotMessage
    }
}

extension reschatSocket.SocketMessage {
    func toMessage() -> MessageProviding {
        self as MessageProviding
    }
    
}
