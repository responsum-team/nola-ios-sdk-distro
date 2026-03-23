// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SocketIO
import Combine

open class ResChatSocket {
    
    // MARK: Combine -
    
    // Messages property -
    internal var _messages = CurrentValueSubject<[SocketMessage], Never>([])
    public var messages: AnyPublisher<[SocketMessage], Never> {
        _messages.eraseToAnyPublisher()
    }
    
    // Messages property -
    internal var _streamingMessage = CurrentValueSubject<SocketMessage, Never>(SocketMessage.none)
    public var streamingMessage: AnyPublisher<SocketMessage, Never> {
        _streamingMessage.eraseToAnyPublisher()
    }
    
    internal var _updatedMessage = CurrentValueSubject<SocketMessage, Never>(SocketMessage.none)
    public var updatedMessage: AnyPublisher<SocketMessage, Never> {
        _updatedMessage.eraseToAnyPublisher()
    }
    
    // Connection state property
    private var _connectionState = CurrentValueSubject<SocketConnectionState, Never>(.disconnected)
    public var connectionState: AnyPublisher<SocketConnectionState, Never> {
        _connectionState.eraseToAnyPublisher()
    }
    
    private var lastStateWasError: Bool = false
    
    // MARK: SocketConnectionState -
    
    private func sendNewSocketConnectionState(_ newState: SocketConnectionState) {
        ParsedResponseLog.shared.logEvent(name: newState.name)
        _connectionState.send(newState)
    }
    
    private var lastKnownConnectedState: SocketConnectionState = .disconnected
    func sendNewConnectedState(_ newState: SocketConnectionState) -> Bool {
        guard newState.isEqualTo(.connected) || newState.isEqualTo(.disconnected) else { return false }
        
        // Check if the state is actually different or if forcing is required
        if !newState.isEqualTo(lastKnownConnectedState)  {
            
            // Update the last known state
            lastKnownConnectedState = newState
            // Clear error dedup flag so next error will be emitted
            lastStateWasError = false

            // Send the state to subscribers
            sendNewSocketConnectionState(newState)
            
            return true
        }
        return false
    }
    
    func sendUpdateConnectionStateError(_ error: Error?) {
        // Deduplicate: don't emit .error again if we're already in error state
        guard !lastStateWasError else {
            print("⚠️ [ResChatSocket] Suppressing duplicate .error state")
            return
        }
        lastStateWasError = true

        // Reset lastKnownConnectedState so that when Socket.IO reconnects,
        // the next .connected is recognized as a state change (not suppressed).
        // Without this, the dedup check in sendNewConnectedState sees
        // .connected == .connected and swallows the reconnection event.
        lastKnownConnectedState = .disconnected

        let socketError = error ?? UnknownStateError.unknownState(message: "Unknown error")
        sendNewSocketConnectionState(.error(socketError))
    }
    
    private var lastKnownLoadingState: SocketConnectionState = .loaded
    func sendNewLoadingState(_ newState: SocketConnectionState) {
        guard newState.isEqualTo(.loading) || newState.isEqualTo(.loaded) else { return }
        
        // Check if the state is actually different or if forcing is required
        if !newState.isEqualTo(lastKnownLoadingState)  {
            
            // Update the last known state
            lastKnownLoadingState = newState
            
            // Send the state to subscribers
            sendNewSocketConnectionState(newState)
        }
    }
    
    private var lastKnownLoadingMoreState: SocketConnectionState = .loadedMore
    func sendNewLoadingMoreState(_ newState: SocketConnectionState) {
        guard newState.isEqualTo(.loadingMore) || newState.isEqualTo(.loadedMore) else { return }
        
        // Check if the state is actually different or if forcing is required
        if !newState.isEqualTo(lastKnownLoadingMoreState)  {
            
            // Update the last known state
            lastKnownLoadingMoreState = newState
            
            // Send the state to subscribers
            sendNewSocketConnectionState(newState)
        }
    }
    
    
    // MARK: Publishers -
    
    // Update messages with a check for duplicates
    func sendHistoryMessagesIfNeeded(newMessages: [SocketMessage], force: Bool = false) {
        if _messages.value != newMessages || force { // TODO: check equality checking -
            _messages.send(newMessages)
        }
    }
    
    func sendStreamingMessage(_ newMessage: SocketMessage) {
        _streamingMessage.send(newMessage)
    }
    
    func sendUpdatedMessage(_ newMessage: SocketMessage) {
        _updatedMessage.send(newMessage)
    }
    
    // MARK: Readonly -
    
    public var socketURL: URL {
        return URL(string: Self.urlString)!
    }
    
    // MARK: Class Properties -
    
    open class var urlString: String { "https://nola-chat.responsum.ai" }
    open class var urlPathString: String { "/ws-public/socket.io/" }
    open class var appId: String { "has" }
    open class var airportId: String { "IAH" }
    public static var language: String = "en"
    public static var location: Location? = nil
    open class var metadata: [String: Any] { makeMetadataWithLocation(location,
                                                                      airportId: airportId,
                                                                      languageAbb: language) }
    
    // MARK: Private Properties -
    
    private(set) var manager: SocketIO.SocketManager!
    private(set) var socket: SocketIOClient!
    private(set) var connectionId: String?
    private(set) var connectParams: [String: Any]
    
    // MARK: Private Helpers -

    // Pagination state
    internal(set) public var historyFinishedLoading = false
    // Loading flag
    internal(set) public var historyIsLoading = false {
        didSet {
            print("historyIsLoading = \(historyIsLoading ? "true" : "false")")
        }
    }

    // MARK: Public Properties -
    
    public var myLocation: Location?
    
    // Public myMetadata property that includes the location if set
    public var myMetadata: [String: Any] {
        Self.makeMetadataWithLocation(myLocation, airportId: Self.airportId, languageAbb: Self.language)
    }
    
    // MARK: Init -

    required public init() {
        let metadata = Self.metadata
        let savedConnectionId = Self.retrieveOrGenerateConnectionId(for: metadata)
        self.connectionId = savedConnectionId
        
        self.connectParams = [
            SocketKey.connectionId.rawValue: savedConnectionId,
            SocketKey.appId.rawValue: Self.appId,
            SocketKey.metadata.rawValue: metadata
        ]
        setupSocket()
        setupSocketEvents()
        
        // Delete the log
        TrafficLog.shared.deleteLog()
        ParsedResponseLog.shared.deleteLog()
    }
    
    // MARK: Setup -

    private func setupSocket() {
        manager = SocketIO.SocketManager(socketURL: socketURL, config: [
            .log(false),
            .compress,
            .path(Self.urlPathString),
            .reconnects(true),
            .reconnectAttempts(-1),   // Unlimited — never give up reconnecting
            .reconnectWait(1),
            .reconnectWaitMax(30),
            .randomizationFactor(0.5) 
        ])
        socket = manager.defaultSocket
    }
    
    internal func resetSocketHelperData() {
        // Reset the flags
        historyFinishedLoading = false
    }
    
    internal func clearCache() {
        sendHistoryMessagesIfNeeded(newMessages: [], force: true)
        resetSocketHelperData()
        sendNewLoadingState(.loading)
    }
}

// MARK: Emit/Send Socket Message -

internal extension ResChatSocket {
    func emitMessage(key: String,
                     payload: [String: Any],
                     callback: @escaping ([Any]) -> Void) {
        
        TrafficLog.shared.logEmitMessage(key: key, payload: payload)
        
        socket.emitWithAck(key,
                           with: [payload]).timingOut(after: 0) { data in
            callback(data)
        }
    }
    
    func sendSocketMessage(key: SocketMessageKey,
                           payload: [String: Any] = [:],
                           socketResponseCallback: @escaping (Response?, String?, String) -> Void = defaultSocketResponseCallback) {
        
        var fullPayload = payload
        fullPayload[SocketKey.connectionId.rawValue] = connectionId
        fullPayload[SocketKey.appId.rawValue] = Self.appId
        fullPayload[SocketKey.metadata.rawValue] = myMetadata
        
        emitMessage(key: key.rawValue, payload: fullPayload) { response in // [Any]
            TrafficLog.shared.logSocketCallback(key: key.rawValue, payload: payload, response: response)
            
            if let parsedResponse = Response.parse(from: response) {
                socketResponseCallback(parsedResponse, fullPayload[SocketKey.message.rawValue] as? String, key.rawValue)
            } else {
                socketResponseCallback(nil, fullPayload[SocketKey.message.rawValue] as? String, key.rawValue)
            }
        }
    }
}

public extension ResChatSocket {
    static func defaultSocketResponseCallback(response: Response?, message: String?, key: String) {
        let theResponse = response?.description ?? "Nil Response"
//        print("DBGG: emitSocketMessage Callback Response for `\(key)`: \(theResponse), \(message ?? "Nil message")")
    }
}

// MARK: ConnectionId per Metadata -

private extension ResChatSocket {
    
    static func stableKey(from metadata: [String: Any]) -> String {
        metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "default"
    }

    static func generateAndSaveConnectionId(for metadata: [String: Any]) -> String {
        let key = stableKey(from: metadata)
        let connectionId = "mobile_iOS_\(UUID().uuidString)"
        UserDefaults.standard.set(connectionId, forKey: "connectionId_\(key)")
        return connectionId
    }

    static func retrieveConnectionId(for metadata: [String: Any]) -> String? {
        let key = stableKey(from: metadata)
        return UserDefaults.standard.string(forKey: "connectionId_\(key)")
    }

    static func deleteConnectionId(for metadata: [String: Any]) {
        let key = stableKey(from: metadata)
        UserDefaults.standard.removeObject(forKey: "connectionId_\(key)")
    }

    static func retrieveOrGenerateConnectionId(for metadata: [String: Any]) -> String {
        retrieveConnectionId(for: metadata) ?? generateAndSaveConnectionId(for: metadata)
    }
}
