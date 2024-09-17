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

// Define a protocol for the ChatViewController that both iOS and macOS versions will conform to
public protocol PlatformChatViewController: AnyObject {
    var proxy: UIDataSource? { get set }
    func subscribeToProxyPublishers()
}

// Associated keys for storing proxy values using Objective-C runtime
private struct AssociatedKeys {
    static var proxy = "proxyKey"
}

// swiftlint:disable unsafe_raw_pointer
// Extend UIViewController and NSViewController to conform to PlatformChatViewController protocol
extension PlatformViewController: PlatformChatViewController {
    // The proxy property, with didSet to trigger subscriptions
    public var proxy: UIDataSource? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.proxy) as? UIDataSource
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.proxy,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            // If you anticipate potential multi-threaded access, consider switching to `OBJC_ASSOCIATION_RETAIN` for thread safety.
            subscribeToProxyPublishers() // Automatically subscribe when the proxy is set
        }
    }

    // Define the required method to handle proxy subscriptions
    public func subscribeToProxyPublishers() {
        // Add logic to subscribe to proxy-related publishers
        print("Subscribing to proxy publishers")
    }
}
// swiftlint:enable unsafe_raw_pointer


/**
 // Example implementation for iOS ChatViewController
 
 import UIKit
 class MyiOSChatViewController: UIViewController, PlatformChatViewController {
     // Implement the required method from PlatformChatViewController
     public func subscribeToProxyPublishers() {
         // Custom logic for proxy subscriptions
         print("iOS: Subscribing to proxy publishers with proxy: \(String(describing: proxy))")
     }

     override func viewDidLoad() {
         super.viewDidLoad()
         // Set the proxy when the view loads
         self.proxy = someProxyDataSource // Replace `someProxyDataSource` with your actual data source
     }
 }

 // Example implementation for macOS ChatViewController
 
 import AppKit
 class MyMacOSChatViewController: NSViewController, PlatformChatViewController {
     // Implement the required method from PlatformChatViewController
     public func subscribeToProxyPublishers() {
         // Custom logic for proxy subscriptions
         print("macOS: Subscribing to proxy publishers with proxy: \(String(describing: proxy))")
     }

     override func viewDidLoad() {
         super.viewDidLoad()
         // Set the proxy when the view loads
         self.proxy = someProxyDataSource // Replace `someProxyDataSource` with your actual data source
     }
 }
 */
