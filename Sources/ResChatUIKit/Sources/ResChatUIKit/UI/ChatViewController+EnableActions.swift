//
//  ChatViewController+EnableActions.swift
//  reschatui
//
//  Created by Mihaela MJ on 27.09.2024..
//
#if os(iOS)
import Foundation
import UIKit

internal extension ChatViewController {
    
    enum BotTypingState {
        case idle
        case placeholderTyping
        case placeholderTypingDone
        case typing
        case typingDone
        
        var isTyping: Bool {
            switch self {
            case /**.typing,*/.placeholderTyping:
                return true
            default:
                return false
            }
        }
    }
    
    func setUserActionsEnabled(_ enabled: Bool) {
        sendButton.isEnabled = enabled
        if usesTextView {
            messageTextField.isEnabled = enabled
        } else {
            messageTextField.isEnabled = enabled
        }
    }

    func handleBotTypingState(_ state: BotTypingState) {
        isSendingEnabled = !state.isTyping
        updateSendingEnabled()
    }

    /// Combines all conditions that determine whether the user can send messages.
    /// Sending is only allowed when the socket is connected AND the bot is not typing.
    func updateSendingEnabled() {
        let canSend = isSocketConnected && isSendingEnabled
        setUserActionsEnabled(canSend)
    }

    /// Shows/hides the small "No connection" indicator above the input bar.
    /// When disconnected and reconnecting, shows a spinner + "Reconnecting…".
    /// When disconnected and not reconnecting, shows wifi.slash + "No connection".
    func updateDisconnectedIndicator(reconnecting: Bool = false) {
        // Don't show the indicator before the first connection attempt has completed.
        // This prevents flashing "No connection" while the socket is still starting up.
        guard hasReceivedConnectionState else { return }

        let icon = disconnectedIndicator.viewWithTag(100) as? UIImageView
        let spinner = disconnectedIndicator.viewWithTag(101) as? UIActivityIndicatorView
        let label = disconnectedIndicator.viewWithTag(102) as? UILabel

        if isSocketConnected {
            UIView.animate(withDuration: 0.25) {
                self.disconnectedIndicator.isHidden = true
                self.disconnectedIndicator.alpha = 0
            }
            spinner?.stopAnimating()
        } else {
            if reconnecting {
                icon?.isHidden = true
                spinner?.startAnimating()
                label?.text = "Reconnecting…"
                label?.textColor = .systemOrange
            } else {
                icon?.isHidden = false
                spinner?.stopAnimating()
                label?.text = "No connection"
                label?.textColor = .systemRed
            }
            UIView.animate(withDuration: 0.25) {
                self.disconnectedIndicator.isHidden = false
                self.disconnectedIndicator.alpha = 1
            }
        }
    }
}
#endif
