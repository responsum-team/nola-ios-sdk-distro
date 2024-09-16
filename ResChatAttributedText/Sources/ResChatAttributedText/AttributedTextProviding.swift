//
//  UIAttributedTextProviding.swift
//  ResChatUIApp
//
//  Created by Mihaela MJ on 14.09.2024..
//

import Foundation
import ResChatProtocols

public protocol AttributedTextProviding {
    static func oneIsEqualToOther(one: NSAttributedString?, other: NSAttributedString?) -> Bool
}

public extension AttributedTextProviding {
    static func oneIsEqualToOther(one: NSAttributedString?, other: NSAttributedString?) -> Bool {
        if let theOne = one, let theOther = other {
            // Both are non-nil, compare them
            return theOne.isEqual(to: theOther)
        } else {
            // Either both are nil, or one is nil and the other isn't
            return one == nil && other == nil
        }
    }
}
