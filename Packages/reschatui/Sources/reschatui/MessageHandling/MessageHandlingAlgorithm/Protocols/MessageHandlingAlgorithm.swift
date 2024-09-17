//
//  MessageHandlingAlgorithm.swift
//
//
//  Created by Mihaela MJ on 17.09.2024..
//

import Foundation
import Combine
import UIKit

protocol MessageHandlingAlgorithm {
    func processHistoryMessages(_ receivedMessages: [UIMessage], dataSource: UIMessageDataSource, completion: @escaping (Bool) -> Void)
    func processStreamingMessage(_ streamingMessage: UIMessage, dataSource: UIMessageDataSource)
    func processUpdatedMessage(_ updatedMessage: UIMessage, dataSource: UIMessageDataSource)
}



