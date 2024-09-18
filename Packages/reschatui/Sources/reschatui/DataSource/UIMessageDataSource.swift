//
//  UIMessageDataSource.swift
//
//
//  Created by Mihaela MJ on 02.09.2024..
//

import UIKit
import ResChatUICommon

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
        snapshot.appendSections([.main])
        snapshot.appendItems(messages, toSection: .main)
        apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Older Message Check -

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

