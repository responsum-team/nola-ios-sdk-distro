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

        // Fires when Socket.IO attempts a reconnect. The data contains the attempt number.
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            let attempt = data.first as? Int ?? -1
            print("🔄 [ResChatSocket] Reconnect attempt #\(attempt)")
        }

        // Fires when Socket.IO has exhausted all reconnection attempts.
        // Transition from .error → .disconnected so the UI stops showing "Reconnecting…"
        // and shows "No connection" instead.
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            guard let self = self else { return }
            let attempt = data.first as? Int ?? 0
            // reconnectAttempts is set to 10 in setupSocket()
            if attempt >= 10 {
                print("🔴 [ResChatSocket] Max reconnect attempts reached — giving up")
                Self.socketEventQueue.async {
                    _ = self.sendNewConnectedState(.disconnected)
                }
            }
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

