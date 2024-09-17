//
//  AirportChooserViewController+MakeUI.swift
//  ResChatUIApp
//
//  Created by Mihaela MJ on 15.09.2024..
//

import Foundation
import ResChatHouCommon
import reschatui
import reschatSocket

public extension AirportChooserViewController {
    func handleSelection(airport: Airport, language: Language) {
        let chatViewController = airport.chatViewControllerForLanguage(language)
        handleSelection(delegate: delegate,
                        airport: airport,
                        language: language,
                        chatViewController: chatViewController)
    }
}

