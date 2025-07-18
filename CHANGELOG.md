## [1.2.10] 2025-07-03

* Updated to target SDK 36

## [1.2.9] 2025-04-11

* Permissions request in the main.dart in example is more fine-grained as per android SDK version

## [1.2.8] 2025-04-07

* Added permissions (bluetooth) for iOS guidance and more permissions in android.manifest

## [1.2.7] 2025-03-07

* Document update for BLE scanning on android

## [1.2.6] 2025-02-17

* Matthias Schicker (komaxx) Makes the plugin compatible Flutter 3.29.0

## [1.2.5] 2024-09-26

* xCode requires the ```current``` folder to be in place and not be a simlink

## [1.2.4] 2024-09-26

* Many thanks to Matthias Schicker for updating to the latest version of the Flic2 framework so builds in ios framework 14

## [1.2.3] 2024-08-20

* The android version of flic2-lib is now hosted by JitPack so updated the gradle build to reflect that. Also upgraded gradle from v7 to v8.

## [1.2.2] 2024-01-22

* Upgraded lint dependencies and check is compiling with latest flutter and gradle versions

## [1.2.1] 2023-10-10

* Accepted pull from Matthias Schicker (komaxx) to make compatible with gradle 8 with code comment (want to keep compatibility with old)

## [1.2.0] 2023-08-05

* Accepted pull from Matthias Schicker (komaxx) to add the function to the available interface to listen to button press and release events from the FLic2 Library

## [1.1.1] 2023-08-05

* Accepted pull from Matthias Schicker (komaxx) to prevent the FlicController sending an 'onButtonScanningStopped' prior to the first 'onButtonScanningStarted' message that it was sending each time you initiated scanning

## [1.1.0] 2023-07-18

* Managing a return of invalid JSON in the name of the Flic2 button now, as well as the example requesting BLUETOOTH_SCAN and BLUETOOTH_CONNECT permissions as now required in Android

## [1.0.2] 2023-05-24

* Exporting the MainActivity for the example to work on newer (API 31+) phones

## [1.0.1] 2023-05-22

* Shrunk the description to get max points in pub.dev

## [1.0.0] 2023-05-22

* Have wrapped the creation of JSON with try--catch to ensure strange names on the flic button no longer cause problems

## [0.1.9] 2023-03-16

* Flic2 on Android requires that the app has permission to FINE_LOCATION, changed the example to request this if missing

## [0.1.8] 2023-03-10

* Updated to the latest flutter and xCode for iOS building properly

## [0.1.7] 2023-03-05

* Upgraded to flutter version 3 and removed the Flic simlinks causing publish to fail

## [0.1.6] 2021-10-05

* Thanks to vanlooverenkoen for fixing some issues with the Json and null battery status'

## [0.1.5] 2021-08-32

* oops - build error

## [0.1.4] 2021-08-32

* iOS click-age now reporting in ms rather than seconds to match the API from android version

## [0.1.3] 2021-08-18

* iOS disposing the plugin doesn't error - returns 'no' or false that it can't. Can start again and it's cool.

## [0.1.2] 2021-08-18

* Changed the Flic2ButtonListener to a mixin so you don't have to overload everything

## [0.1.1] 2021-08-18

* Used <dart pub publish> to push the package to pub.dev and assigned it to a verified publisher

## [0.1.0] 2021-08-18

* The initial release is tested through the provided example/main.dart and working on Android and iOS
