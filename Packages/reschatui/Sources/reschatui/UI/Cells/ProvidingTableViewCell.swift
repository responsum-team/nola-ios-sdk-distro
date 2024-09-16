//
//  File.swift
//  
//
//  Created by Mihaela MJ on 04.06.2024..
//

import UIKit
import ResChatAppearance

open class ProvidingTableViewCell: UITableViewCell {
    open class var identifier: String { "ProvidingTableViewCell" }
    open class var imageProvider: ImageProviding { ResChatAppearance.DefaultImageProvider() }
    open class var colorProvider: ColorProviding {  ResChatAppearance.DefaultColorProvider() }
    
    func configureForDebugging(with type: UIMessageType) {
        return
        #if DEBUG
        let isDebugging = true
        #else
        let isDebugging = false
        #endif
        
        if type.isPlaceholder && isDebugging {
            // Set a subtle yellowish background color for visibility during debugging
            self.contentView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 0.5)
            
            // Add rounded corners
            self.contentView.layer.cornerRadius = 8.0
            self.contentView.layer.masksToBounds = true
            
            // Add a shadow effect for a polished look
            self.contentView.layer.shadowColor = UIColor.black.cgColor
            self.contentView.layer.shadowOpacity = 0.3
            self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.contentView.layer.shadowRadius = 4.0
            self.contentView.layer.masksToBounds = false
        } else {
            // Reset to the default background and remove shadow
            self.contentView.backgroundColor = Self.colorProvider.backgroundColor
            self.contentView.layer.cornerRadius = 0.0
            self.contentView.layer.shadowOpacity = 0.0
        }
    }
}


// Protocol to handle cell configuration
protocol ConfigurableMessageCell {
    func configure(with message: UIMessage)
}

// Conforming your cells to the protocol
extension UserMessageCell: ConfigurableMessageCell {}
extension ChatBotMessageCell: ConfigurableMessageCell {}
extension LoadingTableViewCell: ConfigurableMessageCell {}
