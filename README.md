# flic_button

A flutter and dart version of the Shortcut Labs Flic button protocol to expose Android and iOS Flic2 functionality to Flutter Apps.

Please see the [official Flic developer docs](https://github.com/50ButtonsEach/flic2-documentation) for more info on Flic2

## Device support

### Currently supported

- [Android](https://github.com/50ButtonsEach/fliclib-android)
- [iOS](https://github.com/50ButtonsEach/fliclib-ios)

### Planned support

- Maybe I'll add Flic (original) support, but I don't know how many of those buttons are around of if it's worth it.
- Hopefully, someone from Flic or Shortcut Labs can take up the mantle and merge it all into one library. I did this myself out of necessity and thought it would be nice to let others use it too.

## Usage

The plugin allows you to search for Flic 2, connect to Flic 2, disconnect and forget Flic 2 buttons
Then, more usefully, receive callbacks from the Flic 2 library to tell you someone pressed the button.

At this time, there is no background service to keep the service alive and callback into flutter if destroyed. However, as long as the flutter app remains alive, so will the Flic 2 support.

A simple usage example:

```dart
import 'package:flic_button/flic_button.dart';

class ButtonListener extends Flic2Listener {
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    print('button ${buttonClick.button.uuid} clicked');
  }
  void onButtonConnected() {
    print('button connected');
  }
  void onButtonDiscovered(String buttonAddress) {
    print('button at $buttonAddress discovered');
  }
  void onButtonFound(Flic2Button button) {
    print('button ${button.uuid} found');
  }
  void onFlic2Error(String error) {
    print('error $error');
  }
  void onPairedButtonDiscovered(Flic2Button button) {
    print('button ${button.uuid} discovered');
  }
  void onScanCompleted() {
    print('scan completed');
  }
  void onScanStarted() {
    print('scan started');
  }
}

void main() {
  
  //DON'T FORGET - you will need to ask for permissions for bluetooth and location to search and use
  //FLIC2 as it is a bluetooth button (use your fave plugin for this yourself)
  
  // YOU WILL ALSO need to add permisions for bluetooth LE accessories in your iOS and Android implementations
  
  FlicButtonPlugin(flic2listener: ButtonListener());
  plugin.scanForFlic2();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/DarkerWaters/flic_button/issues


## License

Dart flic_button by Douglas Brain is licensed under MIT LICENCE

