import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

enum Flic2ButtonConnectionState {
  disconnected,
  connecting,
  connecting_starting,
  connected_ready,
}

class Flic2Button {
  /// the unique ID of this button - a long ugly string
  final String uuid;

  /// the bluetooth address of this button
  final String buttonAddr;

  /// the time at which this button became ready last (not iOS)
  final int readyTimestamp;

  /// the friendly name of this button
  final String name;

  /// the serial number of this button
  final String serialNo;

  /// is this button connected etc
  final Flic2ButtonConnectionState connectionState;

  /// the firmware version
  final int firmwareVersion;

  /// the state of the battery % so from 0 - 100
  final int battPercentage;

  /// the timestamp the batter data was stored (not iOS)
  final int battTimestamp;

  /// the current voltage of the battery
  final double battVoltage;

  /// a global counter of how often this button has been clicked
  final int pressCount;

  /// constructor
  const Flic2Button({
    required this.uuid,
    required this.buttonAddr,
    required this.readyTimestamp,
    required this.name,
    required this.serialNo,
    required this.connectionState,
    required this.firmwareVersion,
    required this.battPercentage,
    required this.battTimestamp,
    required this.battVoltage,
    required this.pressCount,
  });
}

class Flic2ButtonClick {
  /// the button
  final Flic2Button button;

  /// was this click stored in the queue, button comes back into range and sends it's cache
  final bool wasQueued;

  /// is this click the last in the queue
  final bool lastQueued;

  /// the age (ms) of this click when in a queue (if it was ages maybe you want to ignore it)
  final int clickAge;

  /// the timestamp of this click from the button (not in iOS)
  final int timestamp;

  /// was this a single click
  final bool isSingleClick;

  /// was this a double click
  final bool isDoubleClick;

  /// was this a long hold of the button
  final bool isHold;

  /// constructor
  const Flic2ButtonClick({
    required this.wasQueued,
    required this.clickAge,
    required this.lastQueued,
    required this.timestamp,
    required this.isSingleClick,
    required this.isDoubleClick,
    required this.isHold,
    required this.button,
  });
}

abstract class Flic2Listener {
  /// called as a button is found by the plugin (while scanning)
  void onButtonFound(Flic2Button button);

  /// called as a button is discovered (by bluetooth address) by the plugin (while scanning)
  void onButtonDiscovered(String buttonAddress);

  /// called as an already paired button is found by the plugin (while scanning)
  void onPairedButtonDiscovered(Flic2Button button);

  /// called by the plugin as a button is clicked
  void onButtonClicked(Flic2ButtonClick buttonClick);

  /// called by the plugin as a button becomes connected
  void onButtonConnected();

  /// called by the plugin as a scan is started
  void onScanStarted();

  /// called by the plugin as a scan is completed
  void onScanCompleted();

  /// called by the plugin as an unexpected error is encountered
  void onFlic2Error(String error);
}

/// the plugin to handle Flic2 buttons
class FlicButtonPlugin {
  static const String _channelName = 'flic_button';
  static const String _methodNameInitialize = 'initializeFlic2';
  static const String _methodNameDispose = 'disposeFlic2';
  static const String _methodNameCallback = 'callListener';

  static const String _methodNameStartFlic2Scan = "startFlic2Scan";
  static const String _methodNameStopFlic2Scan = "stopFlic2Scan";
  static const String _methodNameStartListenToFlic2 = "startListenToFlic2";
  static const String _methodNameStopListenToFlic2 = "stopListenToFlic2";

  static const String _methodNameGetButtons = "getButtons";
  static const String _methodNameGetButtonsByAddr = "getButtonsByAddr";

  static const String _methodNameConnectButton = "connectButton";
  static const String _methodNameDisconnectButton = "disconnectButton";
  static const String _methodNameForgetButton = "forgetButton";

  static const String ERROR_CRITICAL = 'CRITICAL';
  static const String ERROR_NOT_STARTED = 'NOT_STARTED';
  static const String ERROR_ALREADY_STARTED = 'ALREADY_STARTED';
  static const String ERROR_INVALID_ARGUMENTS = 'INVALID_ARGUMENTS';

  static const int METHOD_FLIC2_DISCOVER_PAIRED = 100;
  static const int METHOD_FLIC2_DISCOVERED = 101;
  static const int METHOD_FLIC2_CONNECTED = 102;
  static const int METHOD_FLIC2_CLICK = 103;
  static const int METHOD_FLIC2_SCANNING = 104;
  static const int METHOD_FLIC2_SCAN_COMPLETE = 105;
  static const int METHOD_FLIC2_FOUND = 106;
  static const int METHOD_FLIC2_ERROR = 200;

  static const MethodChannel _channel = const MethodChannel(_channelName);

  Future<bool?>? _invokationFuture;

  final Flic2Listener flic2listener;

  FlicButtonPlugin({required this.flic2listener}) {
    // set the callback handler to ours to receive all our data back after
    // initialized
    _channel.setMethodCallHandler(_methodCallHandler);
    // an invoke the function to initialise the handling of Flic 2
    _invokationFuture = _channel.invokeMethod<bool>(_methodNameInitialize);
  }

  /// accessor to get the invokation future so your UI can wait till it's running properly
  Future<bool?>? get invokation {
    return _invokationFuture;
  }

  /// dispose of this plugin to shut it all down (iOS doesn't at the moment)
  Future<bool?> disposeFlic2() async {
    // this just stops the FLIC 2 manager if not started that's ok
    return _channel.invokeMethod<bool>(_methodNameDispose);
  }

  /// initiate a scan for buttons
  Future<bool?> scanForFlic2() async {
    // scan for flic 2 buttons then please
    return _channel.invokeMethod<bool>(_methodNameStartFlic2Scan);
  }

  /// cancel any running scan
  Future<bool?> cancelScanForFlic2() async {
    // scan for flic 2 buttons then please
    return _channel.invokeMethod<bool>(_methodNameStopFlic2Scan);
  }

  /// connect a button for use
  Future<bool?> connectButton(String buttonUuid) async {
    // connect this button then please
    return _channel.invokeMethod<bool>(_methodNameConnectButton, [buttonUuid]);
  }

  /// disconnect a button to stop using
  Future<bool?> disconnectButton(String buttonUuid) async {
    // disconnect this button then please
    return _channel
        .invokeMethod<bool>(_methodNameDisconnectButton, [buttonUuid]);
  }

  /// have the manager forget the button (so you can scan again and connect again)
  Future<bool?> forgetButton(String buttonUuid) async {
    // forget this button then please
    return _channel.invokeMethod<bool>(_methodNameForgetButton, [buttonUuid]);
  }

  /// listen to the button (android only, or can commonly ignore)
  Future<bool?> listenToFlic2Button(String buttonUuid) async {
    // scan for flic 2 buttons then please
    return _channel
        .invokeMethod<bool>(_methodNameStartListenToFlic2, [buttonUuid]);
  }

  /// stop listening to a button (not iOS)
  Future<bool?> cancelListenToFlic2Button(String buttonUuid) async {
    // scan for flic 2 buttons then please
    return _channel
        .invokeMethod<bool>(_methodNameStopListenToFlic2, [buttonUuid]);
  }

  /// get all the flic 2 buttons the manager is currently aware of (will remember between sessions)
  Future<List<Flic2Button>> getFlic2Buttons() async {
    // get the buttons
    final buttons = await _channel.invokeMethod<List?>(_methodNameGetButtons);
    if (null == buttons) {
      return [];
    } else {
      return buttons.map((e) => _createFlic2FromData(e)).toList();
    }
  }

  /// when a button is discovered, you can just get the bluetooth address, this let's you see if there's a button behind that
  Future<Flic2Button?> getFlic2ButtonByAddress(String buttonAddress) async {
    // scan for flic 2 buttons then please
    final buttonString = await _channel
        .invokeMethod<String?>(_methodNameGetButtonsByAddr, [buttonAddress]);
    if (buttonString == null || buttonString.isEmpty) {
      // not a valid button
      return null;
    } else {
      return _createFlic2FromData(buttonString);
    }
  }

  /// helper to convert the int from the native to a nice enum
  Flic2ButtonConnectionState _connectionStateFromChannelCode(int code) {
    switch (code) {
      case 0:
        return Flic2ButtonConnectionState.disconnected;
      case 1:
        return Flic2ButtonConnectionState.connecting;
      case 2:
        return Flic2ButtonConnectionState.connecting_starting;
      case 3:
        return Flic2ButtonConnectionState.connected_ready;
      default:
        return Flic2ButtonConnectionState.disconnected;
    }
  }

  /// helper to convert the json from native to the object passed around in flutter
  Flic2Button _createFlic2FromData(Object data) {
    try {
      // create a button from this json data
      var json;
      if (data is String) {
        // from string data, let's get the map of data
        json = jsonDecode(data);
      } else {
        // this is JSON already, so just use as-is
        json = data;
      }
      return Flic2Button(
        uuid: json['uuid'],
        buttonAddr: json['bdAddr'],
        readyTimestamp: json['readyTime'],
        name: json['name'],
        serialNo: json['serialNo'],
        connectionState: _connectionStateFromChannelCode(json['connection']),
        firmwareVersion: json['firmwareVer'],
        battPercentage: json['battPerc'],
        battTimestamp: json['battTime'],
        battVoltage: json['battVolt'],
        pressCount: json['pressCount'],
      );
    } catch (error) {
      print('data back is not a valid button: $data $error');
      // return an error button
      return Flic2Button(
          uuid: '',
          buttonAddr: '',
          readyTimestamp: 0,
          name: '',
          serialNo: '',
          connectionState: Flic2ButtonConnectionState.disconnected,
          firmwareVersion: 0,
          battPercentage: 0,
          battTimestamp: 0,
          battVoltage: 0.0,
          pressCount: 0);
    }
  }

  /// helper to convert the json from native to the object passed around in flutter
  Flic2ButtonClick _createFlic2ClickFromData(String data) {
    try {
      final json = jsonDecode(data);
      return Flic2ButtonClick(
        wasQueued: json['wasQueued'],
        clickAge: json['clickAge'],
        lastQueued: json['lastQueued'],
        timestamp: json['timestamp'],
        isSingleClick: json['isSingleClick'],
        isDoubleClick: json['isDoubleClick'],
        isHold: json['isHold'],
        button: _createFlic2FromData(json['button']),
      );
    } catch (error) {
      print('data back is not a valid click: $data $error');
      // return error button click data
      return Flic2ButtonClick(
        wasQueued: false,
        clickAge: 0,
        lastQueued: false,
        timestamp: 0,
        isSingleClick: false,
        isDoubleClick: false,
        isHold: false,
        button: _createFlic2FromData(''),
      );
    }
  }

  /// called back from the native with the relevant data
  Future<void> _methodCallHandler(MethodCall call) async {
    // this is called from the other side when there's something happening in whic
    // we are interested, the ID of the method determines what is sent back
    switch (call.method) {
      case _methodNameCallback:
        // this is a nice callback from the implementation - call the proper
        // function that is required then (by the passed data)
        final methodId = call.arguments['method'] ?? '';
        final methodData = call.arguments['data'] ?? '';
        // get the callback that's registered with this ID to call it
        switch (methodId) {
          case METHOD_FLIC2_DISCOVER_PAIRED:
            // process this method - have discovered a paired flic 2 button
            flic2listener
                .onPairedButtonDiscovered(_createFlic2FromData(methodData));
            break;
          case METHOD_FLIC2_DISCOVERED:
            // process this method - have discovered a flic 2 button, but just the address which isn't great
            flic2listener.onButtonDiscovered(methodData);
            break;
          case METHOD_FLIC2_CONNECTED:
            // process this method - have connected a flic 2 button
            flic2listener.onButtonConnected();
            break;
          case METHOD_FLIC2_FOUND:
            // process this method - have found a flic 2 button
            flic2listener.onButtonFound(_createFlic2FromData(methodData));
            break;
          case METHOD_FLIC2_CLICK:
            // process this method - have clicked a flic 2 button
            flic2listener
                .onButtonClicked(_createFlic2ClickFromData(methodData));
            break;
          case METHOD_FLIC2_SCANNING:
            // process this method - scanning for buttons
            flic2listener.onScanStarted();
            break;
          case METHOD_FLIC2_SCAN_COMPLETE:
            // process this method - scanning for buttons completed
            flic2listener.onScanCompleted();
            break;
          case METHOD_FLIC2_ERROR:
            // process this method - scanning for buttons completed
            flic2listener.onFlic2Error(methodData);
            break;
          default:
            print('unrecognised method callback encountered $methodId');
            break;
        }
        break;
      default:
        print('Ignoring unrecognosed invoke from native ${call.method}');
        break;
    }
  }
}
