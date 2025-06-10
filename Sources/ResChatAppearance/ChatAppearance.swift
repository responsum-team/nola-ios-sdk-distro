//
//  ResChatAppearance.swift
//  NolaChat
//
//  Created by Tin Jurkovic on 10.06.2025..
//

import Foundation

/// Central appearance configuration manager for the Nola SDK
/// Allows users to easily customize colors, images, and navigation bar appearance
public final class ChatAppearance {
    
    // MARK: - Singleton
    public static let shared = ChatAppearance()
    
    // MARK: - Provider Properties
    /// Color provider for customizing chat colors
    public static var colorProvider: ColorProviding = DefaultColorProvider() {
        didSet {
            shared._colorProvider = colorProvider
        }
    }
    
    /// Image provider for customizing chat icons
    public static var imageProvider: ImageProviding = DefaultImageProvider() {
        didSet {
            shared._imageProvider = imageProvider
        }
    }
    
    /// Navigation bar provider for customizing navigation appearance
    public static var navigationBarProvider: NavigationBarProviding = DefaultNavigationBarProvider() {
        didSet {
            shared._navigationBarProvider = navigationBarProvider
        }
    }
    
    // MARK: - Internal Properties
    internal var _colorProvider: ColorProviding = DefaultColorProvider()
    internal var _imageProvider: ImageProviding = DefaultImageProvider()
    internal var _navigationBarProvider: NavigationBarProviding = DefaultNavigationBarProvider()
    
    // MARK: - Initialization
    private init() {
        // Private initializer for singleton
    }
    
    // MARK: - Convenience Access Methods
    /// Get the current color provider
    public static var colors: ColorProviding {
        return shared._colorProvider
    }
    
    /// Get the current image provider
    public static var images: ImageProviding {
        return shared._imageProvider
    }
    
    /// Get the current navigation bar provider
    public static var navigationBar: NavigationBarProviding {
        return shared._navigationBarProvider
    }
    
    // MARK: - Reset Method
    /// Reset all providers to their default values
    public static func resetToDefaults() {
        colorProvider = DefaultColorProvider()
        imageProvider = DefaultImageProvider()
        navigationBarProvider = DefaultNavigationBarProvider()
    }
    
    // MARK: - Bulk Configuration Method
    /// Configure all providers at once
    public static func configure(
        colors: ColorProviding? = nil,
        images: ImageProviding? = nil,
        navigationBar: NavigationBarProviding? = nil
    ) {
        if let colors = colors {
            colorProvider = colors
        }
        if let images = images {
            imageProvider = images
        }
        if let navigationBar = navigationBar {
            navigationBarProvider = navigationBar
        }
    }
}

public final class ResChatAppearanceBuilder {
    private var colorProvider: ColorProviding?
    private var imageProvider: ImageProviding?
    private var navigationBarProvider: NavigationBarProviding?
    
    public init() {}
    
    @discardableResult
    public func colors(_ provider: ColorProviding) -> ResChatAppearanceBuilder {
        self.colorProvider = provider
        return self
    }
    
    @discardableResult
    public func images(_ provider: ImageProviding) -> ResChatAppearanceBuilder {
        self.imageProvider = provider
        return self
    }
    
    @discardableResult
    public func navigationBar(_ provider: NavigationBarProviding) -> ResChatAppearanceBuilder {
        self.navigationBarProvider = provider
        return self
    }
    
    public func apply() {
        ChatAppearance.configure(
            colors: colorProvider,
            images: imageProvider,
            navigationBar: navigationBarProvider
        )
    }
}

public extension ChatAppearance {
    /// Create a builder for fluent configuration
    static func builder() -> ResChatAppearanceBuilder {
        return ResChatAppearanceBuilder()
    }
}
