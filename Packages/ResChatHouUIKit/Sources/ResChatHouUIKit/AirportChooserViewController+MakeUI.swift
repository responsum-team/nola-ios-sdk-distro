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
        
        ResChatSocket.language = language.abbreviation
        
        // TODO: You can set current location if you want to!!!
        ResChatSocket.location = nil
        
        let socket = airport.socket
        
        let chatViewController = airport.chatViewControllerForLanguage(language)
        
        // Call the delegate method
        delegate?.didSelectAirport(airport,
                                   language: language,
                                   socket: socket,
                                   chatViewController: chatViewController,
                                   chooserViewController: self)
    }
}

/**
 # Usage
 
 ```swift
 class ParentViewController: UIViewController, AirportChooserDelegate {
     
     func didSelectAirport(_ airport: Airport, language: Language, socket: ResChatSocket, chatViewController: ChatViewController) {
         // Handle the selected airport and language
         print("Airport selected: \(airport.name), Language selected: \(language.rawValue)")
         
         // Do something with the socket and chatViewController
         setupChat(with: socket, viewController: chatViewController)
     }
     
     func setupChat(with socket: ResChatSocket, viewController: ChatViewController) {
         // Setup the chat using the selected socket and view controller
         // Example: Navigate to the chat view controller
         navigationController?.pushViewController(viewController, animated: true)
     }
 }
 ```
 */
