//
//  ChatBotMessageCell+Configure.swift
//  reschatui
//
//  Created by Mihaela MJ on 18.09.2024..
//

import UIKit
import ResChatUICommon

extension ChatBotMessageCell {
    public func configure(with message: UIMessage) {
        // Update timestamp and setup debugging configuration
        timestampLabel.text = message.date.description
        configureForDebugging(with: message.type)
        
        // Reset any ongoing animations on the messageLabel
        resetMessageLabelAnimation()

        if isEmptyBotHistory(message: message) {
            // No animation needed, update message label directly
            stopPlaceholderAnimation()
            updateMessageLabel(with: message)
        } else if shouldAnimatePlaceholder(for: message) {
            // Handle placeholder animation for bot messages
            handlePlaceholderAnimation()
        } else {
            // Reset placeholder animation if it's not needed anymore
            stopPlaceholderAnimation()
            updateMessageLabel(with: message)

            // If the message is finished and from a specific origin, apply pulse animation
            if message.isFinished && message.origin == .updateItem {
                animatePulse()
            }
        }
    }

    // MARK: - Helper Methods

    private func resetMessageLabelAnimation() {
        messageLabel.layer.removeAllAnimations()
        messageLabel.alpha = 1.0
    }

    private func isEmptyBotHistory(message: UIMessage) -> Bool {
        return (message.origin == .history || message.origin == .updateItem)
        && message.isBotWaiting
    }

    private func shouldAnimatePlaceholder(for message: UIMessage) -> Bool {
        return message.type == .placeholder(.forBot) || message.isBotWaiting
    }

    private func handlePlaceholderAnimation() {
        guard !isAnimatingPlaceholder else { return }

        let attributedText = createPlaceholderAttributedText()
        messageLabel.attributedText = attributedText
        
        // Animate placeholder
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            self.messageLabel.alpha = 0.5
        } completion: { _ in
            self.messageLabel.alpha = 1.0
        }

        isAnimatingPlaceholder = true
    }

    private func stopPlaceholderAnimation() {
        isAnimatingPlaceholder = false
    }

    private func createPlaceholderAttributedText() -> NSAttributedString {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let symbolImage = UIImage(systemName: "ellipsis.circle.fill", withConfiguration: symbolConfiguration)?
            .withTintColor(.systemGray, renderingMode: .alwaysOriginal)

        let attachment = NSTextAttachment()
        attachment.image = symbolImage

        let attributedText = NSMutableAttributedString(string: "Bot is typing... ")
        let symbolAttributedString = NSAttributedString(attachment: attachment)
        attributedText.append(symbolAttributedString)
        
        return attributedText
    }

    private func updateMessageLabel(with message: UIMessage) {
        if !message.attributexTextMatches() {
            print("WARNING: Message text does not match attributed text")
        }
        messageLabel.attributedText = message.attributedText
    }
}
