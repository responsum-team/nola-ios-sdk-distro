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

        // Fires on each reconnect attempt. The data value counts remaining attempts
        // (e.g. 10, 9, 8... 1 for 10 configured attempts).
        // When remaining reaches 1 (last attempt), we wait briefly then check if
        // the socket is still not connected — if so, transition to .disconnected.
        socket.on(clientEvent: .reconnectAttempt) { [weak self] data, ack in
            guard let self = self else { return }
            let remaining = data.first as? Int ?? -1
            print("🔄 [ResChatSocket] Reconnect attempt (remaining: \(remaining)) | status: \(self.socket.status)")

            if remaining <= 1 {
                // This is the last attempt. Wait for it to complete before deciding.
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                    guard let self = self else { return }
                    if self.socket.status != .connected {
                        print("🔴 [ResChatSocket] Final reconnect attempt failed — transitioning to disconnected")
                        Self.socketEventQueue.async {
                            _ = self.sendNewConnectedState(.disconnected)
                        }
                    }
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

