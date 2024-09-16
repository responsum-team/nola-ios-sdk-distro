//
//  AirportChooserDelegate.swift
//
//
//  Created by Mihaela MJ on 15.09.2024..
//

import reschatSocket
import reschatui
import ResChatHouCommon

// Define the delegate protocol
public protocol AirportChooserDelegate: AnyObject {
    func didSelectAirport(_ airport: Airport, language: Language, socket: ResChatSocket, chatViewController: ChatViewController, chooserViewController: AirportChooserViewController)
}
