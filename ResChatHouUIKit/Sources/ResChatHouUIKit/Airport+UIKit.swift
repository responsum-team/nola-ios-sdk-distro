//
//  Airport+UIKit.swift
//  
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import reschatui
import ResChatHouCommon

public extension Airport {
    func chatViewControllerForLanguage(_ language: Language) -> ChatViewController {
        let locale = language.locale
        switch self {
        case .iah: return IAHChatViewController(speechRecognizer: DefaultSpeechRecognizer(locale: locale))
        case .hou: return HOUChatViewController(speechRecognizer: DefaultSpeechRecognizer(locale: locale))
        }
    }
}
