//
//  AppDelegate.swift
//  ResChatIOSApp
//
//  Created by Mihaela MJ on 15.09.2024..
//

import UIKit
import ResChatHouCommon
import ResChatHouUIKit

import reschatui
import reschatSocket
import reschatproxy
import ResChatProtocols

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: Chat -
    var socket: ResChatSocket? {
        didSet {
            let socketValueHasChanged = (oldValue !== socket)
            guard socketValueHasChanged else { return }
            
            // disconnect old socket if it has changed
            if let oldSocket = oldValue {
                stopSocket(socket: oldSocket)
            }
            
            // connect new socket if it is set
            if let newSocket = socket {
                startSocket(socket: newSocket)
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = makeChooserController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        return true
    }
}

// MARK: Choose Airport -

private extension AppDelegate {
    func makeChooserController() -> UIViewController {
        let chooserVC = AirportChooserViewController.make()
        chooserVC.delegate = self
        let navigationController = UINavigationController()
        navigationController.viewControllers = [chooserVC]
        return navigationController
    }
}


extension AppDelegate: AirportAndLanguageChooserDelegate {
    func didSelectAirport(_ airport: ResChatHouCommon.Airport,
                          language: ResChatHouCommon.Language,
                          socket: reschatSocket.ResChatSocket,
                          chatViewController: any ResChatProtocols.PlatformChatViewController,
                          chooserViewController: ResChatProtocols.PlatformAirportViewController) {
        
        
        // TODO: You can set current location if you want to!!!
        ResChatSocket.location = nil
        
        print("Airport selected: \(airport.name), Language selected: \(language.rawValue)")
        
        guard let uiProvidingController = chatViewController as? reschatui.ChatViewController else {
            print("uiProvidingController is not `reschatui.ChatViewController`!!")
            return
        }
        
        let proxy = reschatproxy.SocketProxy(socketProviding: socket,
                                             uiProviding: uiProvidingController)
        chatViewController.proxy = proxy
        
        self.socket = socket
        
        if let airportChooserVC = chooserViewController as? ResChatHouUIKit.AirportChooserViewController {
            // INFO: insert it into navigation stack -
            airportChooserVC.navigationController?.pushViewController(uiProvidingController, animated: true)
        } else {
            print("Error: airportChooserVC is not `ResChatHouUIKit.AirportChooserViewController`!!")
        }
        

        
    }
}

// MARK: Socket -

extension AppDelegate {
    private func startSocket(socket: ResChatSocket) {
        socket.connect()
    }
    
    private func stopSocket(socket: ResChatSocket) {
        socket.disconnect()
    }
}

// MARK: Terminate -

extension AppDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Optionally disconnect the socket if not required in the background
        socket?.disconnect() // Disconnect the socket to save resources
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reconnect the socket when the app comes to the foreground
        socket?.connect() // Reconnect the socket to resume updates
    }

    func applicationWillTerminate(_ application: UIApplication) {
        socket?.disconnect() // Clean up the socket when the app is terminated
    }
}
