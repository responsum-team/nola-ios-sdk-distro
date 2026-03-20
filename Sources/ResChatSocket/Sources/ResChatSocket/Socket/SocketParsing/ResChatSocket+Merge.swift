//
//  ResChatSocket+Merge.swift
//
//
//  Created by Mihaela MJ on 08.09.2024..
//

import Foundation

// MARK: Process -

internal extension ResChatSocket {
    
    // remove duplicates, sort by timestamp
    func normalizeHistoryMessages(_ historyMessages: [SocketMessage]) -> [SocketMessage] {
        let deduped = Array(Set(historyMessages))
        let sorted = SocketMessage.sortMessagesByDate(in: deduped, ascending: true)
        return sorted
    }
}
