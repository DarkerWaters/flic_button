# flic_button

A flutter and dart version of the Shortcut Labs Flic button protocol to expose Android and iOS Flic2 functionality to Flutter Apps.

Please see the [official Flic developer docs](https://github.com/50ButtonsEach/flic2-documentation) for more info on Flic2

## Device support

### Currently supported

- [Android](https://github.com/50ButtonsEach/flic2lib-android)
- [iOS](https://github.com/50ButtonsEach/flic2lib-ios)

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
```groovy
Android {
  defaultConfig {
     minSdkVersion: 19
```

### Building with Gradle 7
The build.gradle needs the namespace defined for newer versions, but not for old, if you have a problem (gradle < 8) you will need to comment out
```
//namespace "uk.co.darkerwaters.flic_button"
```
in the ./android/build.gradle file

### Add permissions for Bluetooth
We need to add the permission to use Bluetooth and access location:

#### **Android**
In the **android/app/src/main/AndroidManifest.xml** let’s add:

```xml 
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

> **NOTE: BLE sccanning**
> If you include this library into your app, the `AndroidManifset.xml` file of the plugin and your own will merge.
> This will result in a declaration of the `BLUETOOTH_SCAN` permission with the remark `neverForLocation` (see [Android documentation](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions#assert-never-for-location)).
> This is correct if you only want to interact with Flic Buttons; however, if your app also needs to scan for BLE devices, this will cause your app to not receive some BLE advertisements, e.g., from iBeacons.
> To correct for this, replace the line for `BLUETOOTH_SCAN` above with:
> ```xml
> <uses-permission android:name="android.permission.BLUETOOTH_SCAN" tools:remove="android:usesPermissionFlags"/>
> ```
> With that, `neverForLocation` will not be included in the merged manifest file, and BLE scanning should work just fine!

#### **IOS**
In the **ios/Runner/Info.plist** let’s add a number of permissions to enable bluetooth and location access. Also needed, at the bottom, is the ability to access BLE in the background...

```xml 
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
  /*
  final isGranted = await Permission.bluetooth.request().isGranted &&
          (!Platform.isAndroid ||
              (await Permission.bluetoothScan.request().isGranted &&
               await Permission.bluetoothConnect.request().isGranted &&
               await Permission.location.request().isGranted
              )
          );
  */
  
  // YOU WILL ALSO need to add permissions for bluetooth LE accessories in your iOS and Android implementations
  
  final plugin = FlicButtonPlugin(flic2listener: ButtonListener());
  _flicPlugin = FlicButtonPlugin(flic2listener: this);
  _flicPlugin.invokation.then((value) {
    // NOTE: value will be true that it initialised unless you already did (iOS can't stop so will be false a lot)
    // which is why I am choosing to ignore the 'value here'
    
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

Dart flic_button by Douglas Brain (Darker Waters LTD) is licensed under the Modified BSD License

