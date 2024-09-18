# ResChatSocketSDK

SDK for Responsum ChatBot

## Usage

### Airport Chooser - starting point

- `AirportChooserViewController` is a part of `ResChatHouUIKit`

Here's the example of creating it:

```swift
    func makeChooserController() -> UIViewController {
        let chooserVC = AirportChooserViewController.make()
        chooserVC.delegate = self
        let navigationController = UINavigationController()
        navigationController.viewControllers = [chooserVC]
        return navigationController
    }
```

- Upon selecting the airport and the language, it instantiates a new socket with pre-populated connection parameters for the airport.
- It also instantiates a UIKit view controller, ChatViewController, for the chosen language (to initialize the speech recognizer with that language).

It provides a delegate that returns all the necessary properties.

You should then create an instance of SocketProxy from the reschatproxy package.
(The idea behind the proxy is to allow the socket to be used with different UI frameworks, such as AppKit or SwiftUI.)

### Putting it all together

here's the example:

```swift
    func didSelectAirport(_ airport: ResChatHouCommon.Airport,
                          language: ResChatHouCommon.Language,
                          socket: reschatSocket.ResChatSocket,
                          chatViewController: any ResChatProtocols.PlatformChatViewController,
                          chooserViewController: ResChatProtocols.PlatformAirportViewController) {
        
        
        // INFO: You can set current location if you want to!!!
        ResChatSocket.location = nil
        
        print("Airport selected: \(airport.name), Language selected: \(language.rawValue)")
        
        guard let uiProvidingController = chatViewController as? reschatui.ChatViewController else { return }
        
        let proxy = reschatproxy.SocketProxy(socketProviding: socket,
                                             uiProviding: uiProvidingController)
        chatViewController.proxy = proxy
        
        self.socket = socket
        
        if let airportChooserVC = chooserViewController as? ResChatHouUIKit.AirportChooserViewController {
            airportChooserVC.navigationController?.pushViewController(uiProvidingController, animated: true)
        }
    }
```

SocketProxy is unaware of the UI framework that uses it and is designed to support both SwiftUI and AppKit.

### Socket:

- It is advisable to instantiate the socket separately, as shown in this example (in AppDelegate or another reliable host).

```swift
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
```

## Customisations

### Parameters (URL, path, name, id):

- In package `ResChatHouCommon`:
  - file `AirportConstants.swift`

### Colors & Images:

- In package `ResChatHouCommon`, files:
  - `HOU+UIProviding.swift`
  - `IAH+UIProviding.swift`

### Languages:

- In package `ResChatHouCommon`, file:
  - `Language.swift`
