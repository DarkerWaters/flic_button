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

## Getting Started
### Change the minSdkVersion for Android

Flic2 buttons are compatible only from version 19 of Android SDK so you should change this in **android/app/build.gradle**:
```dart
Android {
  defaultConfig {
     minSdkVersion: 19
```
### Add permissions for Bluetooth
We need to add the permission to use Bluetooth and access location:

#### **Android**
In the **android/app/src/main/AndroidManifest.xml** let’s add:

```xml 
	 <uses-permission android:name="android.permission.BLUETOOTH" />  
	 <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />  
	 <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>  
 <application
```
#### **IOS**
In the **ios/Runner/Info.plist** let’s add a number of permissions to enable bluetooth and location access. Also needed, at the bottom, is the ability to access BLE in the background...

```dart 
	<dict>  
	    <key>NSBluetoothAlwaysUsageDescription</key>  
	    <string>Need BLE permission</string>  
	    <key>NSBluetoothPeripheralUsageDescription</key>  
	    <string>Need BLE permission</string>  
	    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  
	    <string>Need Location permission</string>  
	    <key>NSLocationAlwaysUsageDescription</key>  
	    <string>Need Location permission</string>  
	    <key>NSLocationWhenInUseUsageDescription</key>  
	    <string>Need Location permission</string>
	    <key>UIBackgroundModes</key>
        <array>
            <string>bluetooth-central</string>
        </array>
```

For location permissions on iOS see more at: [https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services)

A simple usage example:

```dart
import 'package:flic_button/flic_button.dart';

class ButtonListener with Flic2Listener {
  void onButtonClicked(Flic2ButtonClick buttonClick) {
    print('button ${buttonClick.button.uuid} clicked');
  }
}

void main() {
  
  //DON'T FORGET - you will need to ask for permissions for bluetooth and location to search and use
  //FLIC2 as it is a bluetooth button (use your fave plugin for this yourself)
  
  // YOU WILL ALSO need to add permisions for bluetooth LE accessories in your iOS and Android implementations
  
  final plugin = FlicButtonPlugin(flic2listener: ButtonListener());
  _flicPlugin = FlicButtonPlugin(flic2listener: this);
  _flicPlugin.invokation.then((value) {
    // have invoked the plugin here, get all the buttons to connect them up
    return _flicPlugin.getFlic2Buttons();
  }).then((value) {
    if (value.isEmpty) {
      // you don't have buttons in the manager, initiate a scan to find and connect a new one
      _flicPlugin.scanForFlic2();
    } else {
      // here we have the buttons, listen to all of them
      for (Flic2Button button in value) {
        // listen to them all!
        _flicPlugin.listenToFlic2Button(button.uuid);
      }
    }
  });
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/DarkerWaters/flic_button/issues


## License

Dart flic_button by Douglas Brain is licensed under MIT LICENCE

