# ResChatSocketSDK

SDK for Responsum ChatBot

## Usage

### Airport Chooser - starting point

- `AirportChooserViewController` is a part of `ResChatHouUIKit`

Here's the example of creating it':

```swift
    func makeChooserController() -> UIViewController {
        let chooserVC = AirportChooserViewController.make()
        chooserVC.delegate = self
        let navigationController = UINavigationController()
        navigationController.viewControllers = [chooserVC]
        return navigationController
    }
```

- Upon choosing the airport and the language, it instantiates a new socket wit repopulated connection params for the airport.
- It also instantiates a UIKit View Controller: `ChatViewController` for the chosen language (to init the speech recognizer with that language)

It provides a `delegate` which returns all needed properties.

You should then make an instance of `SocketProxy` from `reschatproxy` package.
(The idea behind the proxy is the ability to use the socket with different UI framework such as AppKit or SwiftUI).

### Putting it all together

here's the example:

```swift
    func didSelectAirport(_ airport: ResChatHouCommon.Airport,
                         language: ResChatHouCommon.Language,
                         socket: reschatSocket.ResChatSocket,
                         chatViewController: reschatui.ChatViewController,
                         chooserViewController: ResChatHouUIKit.AirportChooserViewController) {

       // TODO: You can set current location if you want to!!!
       ResChatSocket.location = nil

       print("Airport selected: \(airport.name), Language selected: \(language.rawValue)")

       let proxy = reschatproxy.SocketProxy(socketProviding: socket,
                                            uiProviding: chatViewController)
       chatViewController.proxy = proxy

       self.socket = socket

       // INFO: insert it into navigation stack -
       chooserViewController.navigationController?.pushViewController(chatViewController, animated: true)
   }
```

`SocketProxy` is oblivious of the UI framework that utilizes it, and is ready to serve both SwiftUI and AppKit.

### Socket:

- It is advisable to instantiate socket separately, like in this example (in `AppDelegate`, or some other reliable host)

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
