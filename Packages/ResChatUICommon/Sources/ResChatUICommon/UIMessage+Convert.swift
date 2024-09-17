//
//  UIMessage+Convert.swift
//  
//
//  Created by Mihaela MJ on 16.09.2024..
//

import Combine
import Foundation
import ResChatProtocols

extension UIMessage: MessageProviding {
    public var isFromBot: Bool { isBot  }
}

public extension ResChatProtocols.MessageType  {
    func toUIMessageType() -> UIMessageType {
        switch self {
        case .user:
            return UIMessageType.user
        case .bot:
            return UIMessageType.bot
        }
    }
}

public extension MessageProviding {
    func toUIMessage() -> UIMessage {
        let uiType = messageType.toUIMessageType()
        
        let result = UIMessage.new(text: text,
                                   rawText: rawText,
                                   type: uiType,
                                   timestamp: timestamp,
                                   messagePart: messagePart,
                                   messageIndex: messageIndex,
                                   isFinished: isFinished)
        return result
    }
}
