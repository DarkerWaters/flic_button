import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void callbackDispatcher() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const MethodChannel _backgroundChannel =
      MethodChannel('flic2_background_channel');

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    final List<dynamic> args = call.arguments;

    // 3.1. Retrieve callback instance for handle.
    final Function? callbackThis = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(args[0]));
    assert(callbackThis != null);

    // 3.2. Preprocess arguments.
    String s = args[1] as String;

    // 3.3. Invoke callback.
    callbackThis!(s);
  });
}
