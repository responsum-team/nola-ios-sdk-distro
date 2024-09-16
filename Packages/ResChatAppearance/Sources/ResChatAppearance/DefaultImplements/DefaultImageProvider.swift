//
//  DefaultImageProvider.swift
//  
//
//  Created by Mihaela MJ on 05.06.2024..
//

public struct DefaultImageProvider: ImageProviding {
    public var chatBotIcon: ImageType? {
        return Self.systemImage(named: "bubble.left.fill")
    }
    public var userIcon: ImageType? {
        return Self.systemImage(named: "person.fill")
    }
    public var sendIcon: ImageType? {
        return Self.systemImage(named: "paperplane.fill")
    }
    public var clearAllIcon: ImageType? {
        return Self.systemImage(named: "trash")
    }
    
    public init() {}
}

extension ImageProviding {
    public static func systemImage(named: String) -> ImageType? {
        #if os(iOS)
        return ImageType(systemName: named)
        #elseif os(macOS)
        return ImageType(systemSymbolName: named, accessibilityDescription: nil)
        #endif
    }
}
