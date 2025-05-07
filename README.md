# Nola SDK

SDK for embedding the Responsum ChatBot in your iOS apps & macOS apps. Note: macOS SDK in beta testing.

> **Latest version:** 1.1.3

---

## Features

- **One-line integration** — present the full chat UI with a single call.  
- **WebSocket-powered chat** — real-time, bidirectional messaging via `ResChatSocket`.  
- **UI framework-agnostic** — works out of the box with UIKit, AppKit, SwiftUI, etc., via `SocketProxy`.  
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
// or the umbrella package name you chose

// 1. Present the chat interface from any UIViewController/NSViewController:
ChatManager.shared.presentResChatInterface(from: self)

// 2. Later, when you're done:
ChatManager.shared.cleanup()
```

That’s it! The SDK handles initial configuration selection, socket lifecycle, UI presentation, and theming.

---

## Customization & Theming

All appearance is driven via three “provider” protocols in `ResChatAppearance`. The SDK ships with default implementations under `ResChatAppearance/DefaultImplements`:

1. **DefaultColorProvider** (`ColorProviding`)  
2. **DefaultImageProvider** (`ImageProviding`)  
3. **DefaultNavigationBarProvider** (`NavigationBarProviding`)

To override:

```swift
// 1. Conform your own providers:
struct MyColors: ColorProviding { … }
struct MyImages: ImageProviding { … }
struct MyNavBar: NavigationBarProviding { … }

// 2. Register them before presenting:
ResChatAppearance.colorProvider = MyColors()
ResChatAppearance.imageProvider = MyImages()
ResChatAppearance.navigationBarProvider = MyNavBar()
```

### Example

Below is a full example showing how to define and register custom theming providers before presenting the chat interface:

```swift
import NolaSDK
import UIKit  // or AppKit on macOS

// 1) Define your custom providers:

struct MyColorProvider: ColorProviding {
    public var textColor: ColorType { .red }
    public var chatBotButtonBackground: ColorType { .green }
    public var userButtonBackground: ColorType { .blue }
    public var backgroundColor: ColorType { .white }
    public var timestampTextColor: ColorType { .gray }
    public var messageTextColor: ColorType { .black }
    public var placeholderMessageTextColor: ColorType { .lightGray }
    public var inputBorderColor: ColorType { .darkGray }
    public var shadowColor: ColorType { .black.withAlphaComponent(0.3) }
    public var sendIconColor: ColorType { .purple }
    
    public init() {}
}

struct MyImageProvider: ImageProviding {
    public var chatBotIcon: ImageType? { MyImageProvider.systemImage(named: "star.fill") }
    public var userIcon: ImageType?    { MyImageProvider.systemImage(named: "heart.fill") }
    public var sendIcon: ImageType?    { MyImageProvider.systemImage(named: "paperplane.fill") }
    public var clearAllIcon: ImageType?{ MyImageProvider.systemImage(named: "trash.fill") }
    
    public init() {}
}

struct MyNavBarProvider: NavigationBarProviding {
    public var backgroundColor: ColorType { MyColorProvider().chatBotButtonBackground }
    public var textColor: ColorType       { .white }
    public var rightButtonImage: ImageType? { MyImageProvider().clearAllIcon }
    public var backButtonImage: ImageType?  { MyImageProvider().chatBotIcon }
    public var title: String               { "My Custom HelpBot" }
    public var font: FontType {
        #if os(iOS)
        return .preferredFont(forTextStyle: .headline)
        #else
        return .systemFont(ofSize: 18, weight: .semibold)
        #endif
    }
    
    public init() {}
}

// 2) Register your custom providers before presenting:

func presentChat(from viewController: UIViewController) {
    ResChatAppearance.colorProvider         = MyColorProvider()
    ResChatAppearance.imageProvider         = MyImageProvider()
    ResChatAppearance.navigationBarProvider = MyNavBarProvider()
    
    ChatManager.shared.presentResChatInterface(from: viewController)
}

// 3) Usage in your view controller:

class ViewController: UIViewController {
    @IBAction func showHelpBot(_ sender: Any) {
        presentChat(from: self)
    }
}
```

---

## Configuration
 
- **Supported languages:** defined in `ResChatHouCommon/Language.swift`.  
- **Default assets (colors & images):** see `HOU+UIProviding.swift`, `IAH+UIProviding.swift`.

---

## Changelog

### v1.1.3
- Minimum iOS deployment version iOS 14

---

### v1.1.2 
- Bugfix: SPM remote handling
- Performance improvements in socket reconnection  

---

Enjoy building with Nola SDK! Pull requests and feedback are always welcome.
