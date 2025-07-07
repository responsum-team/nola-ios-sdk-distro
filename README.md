# Nola SDK

SDK for embedding the Responsum ChatBot in your iOS apps & macOS apps. Note: macOS SDK in alpha testing.

> **Latest version:** 1.1.5

---

## Features

- **One-line integration** — present the full chat UI with a single call.  
- **WebSocket-powered chat** — real-time, bidirectional messaging via ResChatSocket.  
- **UI framework-agnostic** — works out of the box with UIKit, AppKit, SwiftUI, etc., via SocketProxy.  
- **Fully themable** — swap out default colors, icons, fonts, and navigation bar.

---

## Requirements

- Xcode 16+  
- Swift 5.6+  
- iOS 14+/macOS 11+  

---

## Installation

### Swift Package Manager

```swift
// In Xcode: File → Add Packages…
https://github.com/responsum-team/nola-ios-sdk-distro.git
```

---

## Quick Start

```swift
import NolaChat

// 1. Present the chat interface from any UIViewController/NSViewController:
ChatManager.shared.start(from: self)

// 2. Later, when you're done:
ChatManager.shared.cleanup()
```

That's it! The SDK handles initial configuration selection, socket lifecycle, UI presentation, and theming.

---

## Customization & Theming

To customize the appearance of the chat interface, you need to modify the provider implementations in the `ResChatHouCommon` package:

- **HOU+UIProviding.swift** - Contains appearance settings for HOU airport selection
- **IAH+UIProviding.swift** - Contains appearance settings for IAH airport selection

Each file contains three provider structs that you can modify:

### ColorProviding Implementation

```swift
struct HOUColorProvider: ColorProviding {
    public var textColor: ColorType { .red } // Main Text Color
    public var chatBotButtonBackground: ColorType { .green } // Chat Bot Icon Button Background Color
    public var userButtonBackground: ColorType { .blue } // User Icon Background Color
    public var backgroundColor: ColorType { .white } // Message Input View Background Color
    public var timestampTextColor: ColorType { .gray } // Timestamp text color
    public var messageTextColor: ColorType { .black } // Message Input Field Text Color
    public var placeholderMessageTextColor: ColorType { .lightGray } // Placeholder Input Field Text Color
    public var inputBorderColor: ColorType { .darkGray } // Input Field Border Color
    public var shadowColor: ColorType { .black.withAlphaComponent(0.3) } // Chat Bot Message Cell Shadow Color
    public var sendIconColor: ColorType { .black } // Send Icon Color
    
    public init() {}
}
```

### ImageProviding Implementation

```swift
struct HOUImageProvider: ImageProviding {
    public var chatBotIcon: ImageType? { UIImage(named: "star.fill") } // Icon for Chat Bot Text
    public var userIcon: ImageType?    { UIImage(named: "heart.fill") } // Icon for User Text
    public var sendIcon: ImageType?    { UIImage(named: "paperplane.fill") } // Icon for send button
    public var clearAllIcon: ImageType?{ UIImage(named: "trash.fill") } // Clear All Icon
    
    public init() {}
}
```

### NavigationBarProviding Implementation

```swift
struct HOUNavigationBarProvider: NavigationBarProviding {
    public var backgroundColor: ColorType { .green} // Background of navigation bar
    public var textColor: ColorType       { .white } // Text color
    public var rightButtonImage: ImageType? { UIImage(named: "trash.fill") } // Image for right button
    public var backButtonImage: ImageType?  { UIImage(named: "chevron.left") } // Image for left button
    public var title: String               { "My Custom HelpBot" } // Title
    public var font: FontType {
        #if os(iOS)
        return .preferredFont(forTextStyle: .headline)
        #else
        return .systemFont(ofSize: 18, weight: .semibold)
        #endif
    }
    
    public init() {}
}
```

**Note:** Modify the appropriate file (`HOU+UIProviding.swift` or `IAH+UIProviding.swift`) based on your airport selection to customize the appearance for your specific use case.

---

## Configuration
 
- **Supported languages:** defined in ResChatHouCommon/Language.swift.  
- **Default assets (colors & images):** see HOU+UIProviding.swift, IAH+UIProviding.swift.

---

## Changelog

### v1.1.5
- Fix issue with airport welcome message.

---

### v1.1.4
- Renaming presentResChatInterface() method into start()
- Improving handling of Appearance - changing values withing the package.
- Renaming ResChatAppearance into ChatAppearance.
- ChatAppearance logic in progress for handling appearance more fluently.
- Additional Improvements & Bugfixes.

---

### v1.1.3
- Minimum iOS deployment version iOS 14

---

### v1.1.2 
- Bugfix: SPM remote handling
- Performance improvements in socket reconnection  

---

Enjoy building with Nola SDK! Pull requests and feedback are always welcome.
