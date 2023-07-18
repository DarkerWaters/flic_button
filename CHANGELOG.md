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
