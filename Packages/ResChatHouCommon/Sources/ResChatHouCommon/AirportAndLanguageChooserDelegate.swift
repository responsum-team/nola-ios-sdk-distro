//
//  PlatformStuff.swift
//  ResChatHouCommon
//
//  Created by Mihaela MJ on 17.09.2024..
//

#if canImport(UIKit)
import UIKit
public typealias PlatformViewController = UIViewController
#elseif canImport(AppKit)
import AppKit
public typealias PlatformViewController = NSViewController
#endif

import reschatSocket
import ResChatProtocols

// Define the AirportChooserDelegate protocol
public protocol AirportAndLanguageChooserDelegate: AnyObject {
    func didSelectAirport(
        _ airport: Airport,
        language: Language,
        socket: ResChatSocket,
        chatViewController: PlatformChatViewController, // Now uses PlatformChatViewController
        chooserViewController: PlatformViewController
    )
}

