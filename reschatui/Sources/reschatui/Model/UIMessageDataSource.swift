//
//  UIMessageDataSource.swift
//
//
//  Created by Mihaela MJ on 02.09.2024..
//

import UIKit

class UIMessageDataSource: UITableViewDiffableDataSource<ChatSection, UIMessage> {
    
    // Initialization
    init(tableView: UITableView,
         userMessageCellType: UserMessageCell.Type,
         botMessageCellType: ChatBotMessageCell.Type,
         loadingMessageCellType: LoadingTableViewCell.Type) {
        
        super.init(tableView: tableView) { (tableView, indexPath, message) -> UITableViewCell? in
            
            switch message.type {
            case .user, .placeholder(.forUser):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: userMessageCellType.identifier,
                    for: indexPath
                ) as? UserMessageCell else { return nil }
                cell.configure(with: message)
                return cell
                
            case .bot, .placeholder(.forBot):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: botMessageCellType.identifier,
                    for: indexPath
                ) as? ChatBotMessageCell else { return nil }
                cell.configure(with: message)
                return cell
                
            case .placeholder(.forLoading):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: loadingMessageCellType.identifier,
                    for: indexPath
                ) as? LoadingTableViewCell else { return nil }
                cell.configure(with: message)
                return cell
            }
        }
    }
    
    // MARK: - Snapshot Management

    func applyInitialSnapshot(messages: [UIMessage]) {
        var snapshot = UIMessageSnapshot()
        snapshot.applyInitialMessages(messages)
        apply(snapshot, animatingDifferences: true)
    }
    
    func clearMessages() {
        var snapshot = UIMessageSnapshot()
        snapshot.clearAllMessages()
        apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Older Message Check

    /// Checks if the received messages are older than the existing ones in the snapshot.
    func areReceivedMessagesOlderThanExisting(receivedMessages: [UIMessage]) -> Bool {
        // Retrieve the current snapshot
        let snapshot = self.snapshot()

        // Find the oldest message in the current snapshot
        if let oldestExistingMessage = snapshot.itemIdentifiers.sorted(by: { $0.date < $1.date }).first,
           let oldestReceivedMessage = receivedMessages.sorted(by: { $0.date < $1.date }).first {
            // Return true if the received messages are older than the oldest existing message
            return oldestReceivedMessage.date < oldestExistingMessage.date
        }

        // If there are no existing or received messages, we can't compare, so return false
        return false
    }

    func areMessagesNewerThanExisting(receivedMessages: [UIMessage]) -> Bool {
        let existingMessages = self.snapshot().itemIdentifiers
        guard let latestReceivedMessage = receivedMessages.max(by: { $0.date < $1.date }),
              let latestExistingMessage = existingMessages.max(by: { $0.date < $1.date }) else {
            // Fallback: assume messages are newer if we can't compare
            return true
        }
        
        return latestReceivedMessage.date > latestExistingMessage.date
    }

    func areMessagesOlderThanExisting(receivedMessages: [UIMessage]) -> Bool {
        let existingMessages = self.snapshot().itemIdentifiers
        guard let earliestReceivedMessage = receivedMessages.min(by: { $0.date < $1.date }),
              let earliestExistingMessage = existingMessages.min(by: { $0.date < $1.date }) else {
            // Fallback: assume messages are older if we can't compare
            return true
        }
        
        return earliestReceivedMessage.date < earliestExistingMessage.date
    }
}

