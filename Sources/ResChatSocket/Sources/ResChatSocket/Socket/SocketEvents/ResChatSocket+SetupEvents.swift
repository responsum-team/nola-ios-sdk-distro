//
//  ResChatSocket+SetupEvents.swift
//
//
//  Created by Mihaela MJ on 02.09.2024..
//

import Foundation
import SocketIO

internal extension ResChatSocket {

    /// Serial queue for all socket event handling.
    /// Prevents race conditions when connect/disconnect/error events arrive
    /// near-simultaneously on different threads.
    static let socketEventQueue = DispatchQueue(label: "com.reschat.socketEvents", qos: .userInitiated)

    func setupSocketEvents() {
        setupConnectionSocketEvents()
        setupCustomSocketEvents()
    }

    func setupConnectionSocketEvents() {
        socket.on(SocketEventKey.connect.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.connect.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                onConnect(data: data, ack: ack)
            }
        }

        socket.on(SocketEventKey.disconnect.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.disconnect.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                onDisconnect(data: data, ack: ack)
            }
        }

        socket.on(SocketEventKey.error.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.error.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                onError(data: data, ack: ack)
            }
        }

        // Fires on each reconnect attempt. With unlimited retries (-1), Socket.IO
        // will keep trying with exponential backoff (1s → 30s) until the server is reachable.
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            guard let self = self else { return }
            let attempt = data.first as? Int ?? -1
            print("🔄 [ResChatSocket] Reconnect attempt \(attempt) | status: \(self.socket.status)")
        }
    }
    
    func setupCustomSocketEvents() {
        socket.on(SocketEventKey.sendHistorySnapshot.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.sendHistorySnapshot.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                handleReceivedConversations(data: data, ack: ack)
            }
        }

        socket.on(SocketEventKey.streamMessage.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.streamMessage.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                handleReceivedStreamMessages(data: data, ack: ack)
            }
        }

        socket.on(SocketEventKey.updateHistoryItem.rawValue) { data, ack in
            TrafficLog.shared.logOnResponse(named: SocketEventKey.updateHistoryItem.rawValue, data: data)
            Self.socketEventQueue.async { [self] in
                handleReceivedUpdateHistoryItems(data: data, ack: ack)
            }
        }
    }
}

