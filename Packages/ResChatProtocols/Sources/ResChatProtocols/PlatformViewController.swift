//
//  PlatformViewController.swift
//  ResChatProtocols
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

import CoreLocation


// Define a protocol for the ChatViewController that both iOS and macOS versions will conform to
public protocol PlatformChatViewController: AnyObject {
    var proxy: UIDataSource? { get set }
    func subscribeToProxyPublishers()
}

public protocol PlatformAirportViewController: AnyObject {
    var location: CLLocation? { get set } // Add CLLocation property
}

// Associated keys for storing proxy values using Objective-C runtime
private struct AssociatedKeys {
    static var proxy = "proxyKey"
    static var location = "locationKey"
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
    @objc open func subscribeToProxyPublishers() {
        // Add logic to subscribe to proxy-related publishers
        print("Subscribing to proxy publishers")
    }
}


extension PlatformViewController: PlatformAirportViewController {
    // The location property, using Objective-C runtime to store the value
    public var location: CLLocation? {
        get {
            return objc_getAssociatedObject(self, UnsafeRawPointer(&AssociatedKeys.location)) as? CLLocation
        }
        set {
            objc_setAssociatedObject(self, UnsafeRawPointer(&AssociatedKeys.location), newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
// swiftlint:enable unsafe_raw_pointer

