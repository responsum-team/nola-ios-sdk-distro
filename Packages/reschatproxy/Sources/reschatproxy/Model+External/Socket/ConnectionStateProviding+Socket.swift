//
//  UIConnectionStateProviding+Socket.swift
//  ResChatUIApp
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import reschatSocket
import ResChatProtocols

extension reschatSocket.SocketConnectionState: ConnectionStateProviding {
    public var toConnectionState: ConnectionState {
        switch self {
        case .connected:
            return ConnectionState.connected
        case .disconnected:
            return ConnectionState.disconnected
        case .loading:
            return ConnectionState.loading
        case .loaded:
            return ConnectionState.loaded
        case .error(let error):
            return ConnectionState.error(error)
        case .loadingMore:
            return ConnectionState.loadingMore
        case .loadedMore:
            return ConnectionState.loadedMore
        }
    }
}

extension ConnectionState {
    public var toSocketConnectionState: reschatSocket.SocketConnectionState {
        switch self {
        case .connected:
            return reschatSocket.SocketConnectionState.connected
        case .disconnected:
            return reschatSocket.SocketConnectionState.disconnected
        case .loading:
            return reschatSocket.SocketConnectionState.loading
        case .loaded:
            return reschatSocket.SocketConnectionState.loaded
        case .error(let error):
            return reschatSocket.SocketConnectionState.error(error)
        case .loadingMore:
            return reschatSocket.SocketConnectionState.loadingMore
        case .loadedMore:
            return reschatSocket.SocketConnectionState.loadedMore
        }
    }
}

