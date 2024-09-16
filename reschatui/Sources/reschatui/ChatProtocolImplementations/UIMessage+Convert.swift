//
//  UIMessage+Convert.swift
//  
//
//  Created by Mihaela MJ on 16.09.2024..
//

import Combine
import Foundation
import ResChatProtocols

extension reschatui.UIMessage: MessageProviding {
    public var isFromBot: Bool { isBot  }
}

extension ResChatProtocols.MessageType  {
    func toUIMessageType() -> reschatui.UIMessageType {
        switch self {
        case .user:
            return reschatui.UIMessageType.user
        case .bot:
            return reschatui.UIMessageType.bot
        }
    }
}
extension MessageProviding {
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
