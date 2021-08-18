package uk.co.darkerwaters.flic_button;

import android.content.Context;
import android.widget.Button;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flic.flic2libandroid.Flic2Button;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlicButtonPlugin */
public class FlicButtonPlugin implements FlutterPlugin, MethodCallHandler {
  public static final String channelName = "flic_button";
  public static final String methodNameInitialise = "initializeFlic2";
  public static final String methodNameDispose = "disposeFlic2";
  public static final String methodNameCallback = "callListener";


  public static final String methodNameStartFlic2Scan = "startFlic2Scan";
  public static final String methodNameStopFlic2Scan = "stopFlic2Scan";
  public static final String methodNameStartListenToFlic2 = "startListenToFlic2";
  public static final String methodNameStopListenToFlic2 = "stopListenToFlic2";

  public static final String methodNameGetButtons = "getButtons";
  public static final String methodNameGetButtonsByAddr = "getButtonsByAddr";

  public static final String methodNameConnectButton = "connectButton";
  public static final String methodNameDisconnectButton = "disconnectButton";
  public static final String methodNameForgetButton = "forgetButton";

  public static final String ERROR_CRITICAL = "CRITICAL";
  public static final String ERROR_NOT_STARTED = "NOT_STARTED";
  public static final String ERROR_ALREADY_STARTED = "ALREADY_STARTED";
  public static final String ERROR_INVALID_ARGUMENTS = "INVALID_ARGUMENTS";

  public static final int METHOD_FLIC2_DISCOVER_PAIRED = 100;
  public static final int METHOD_FLIC2_DISCOVERED = 101;
  public static final int METHOD_FLIC2_CONNECTED = 102;
  public static final int METHOD_FLIC2_CLICK = 103;
  public static final int METHOD_FLIC2_SCANNING = 104;
  public static final int METHOD_FLIC2_SCAN_COMPLETE = 105;
  public static final int METHOD_FLIC2_FOUND = 106;
  public static final int METHOD_FLIC2_ERROR = 200;

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  // we can and want to control a Flic2 then
  private Flic2Controller flic2Controller = null;

  private Context context = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channelName);
    this.channel.setMethodCallHandler(this);
    // we will need the application context later for when they start the service or whatever
    this.context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    // and shutdown anything else started
    if (null != this.flic2Controller) {
      this.flic2Controller.releaseFlic();
      this.flic2Controller = null;
    }
  }

  private String extractStringArgument(String functionName, String paramName, Object arguments, @NonNull final Result result) {
    String toReturn = null;
    if (!(arguments instanceof List)) {
      result.error(ERROR_INVALID_ARGUMENTS,
              "The list passed to " + functionName + " is not valid",
              arguments == null ? "null" : arguments.toString());
    } else if (null == this.flic2Controller) {
      // already started
      result.error(ERROR_NOT_STARTED, "Flic 2 hasn't been started", "Flic 2 isn't running so we can't " + functionName);
    } else {
      List<?> args = (List<?>) arguments;
      // and we can check the argument passed in is the button ID
      if (args.size() != 1 || !(args.get(0) instanceof String)) {
        // there should only be one argument
        result.error(ERROR_INVALID_ARGUMENTS,
                "The list passed to " + functionName + " should just contain the " + paramName,
                arguments.toString());
      } else {
        // it's a string
        toReturn = (String) args.get(0);
      }
    }
    // and return the extracted (null if not okay)
    return toReturn;
  }

  private static String ButtonToJson(Flic2Button button) {
    return "{" +
            "\"uuid\":\"" + button.getUuid() + "\"," +
            "\"bdAddr\":\"" + button.getBdAddr() + "\"," +
            "\"readyTime\":" + button.getReadyTimestamp() + "," +
            "\"name\":\"" + button.getName() + "\"," +
            "\"serialNo\":\"" + button.getSerialNumber() + "\"," +
            "\"connection\":" + button.getConnectionState() + "," +
            "\"firmwareVer\":" + button.getFirmwareVersion() + "," +
            "\"battPerc\":" + button.getLastKnownBatteryLevel().getEstimatedPercentage() + "," +
            "\"battTime\":" + button.getLastKnownBatteryLevel().getTimestampUtcMs() + "," +
            "\"battVolt\":" + button.getLastKnownBatteryLevel().getVoltage() + "," +
            "\"pressCount\":" + button.getPressCount() + "" +
            "}";
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals(methodNameInitialise)) {
      // this is easy - start Flic
      if (null != this.flic2Controller) {
        // already started
        result.error(ERROR_ALREADY_STARTED, "Flic 2 has been initialized already", "Flic 2 started already, okay to call twice but won't do anything...");
      } else if (null == this.context) {
        result.error(ERROR_CRITICAL, "There's no context", "The flutter engine didn't attach with a valid application context, sorry but we can't start Flic2");
      } else {
        // start Flic 2 then
        this.flic2Controller = new Flic2Controller(context, flic2Callback);
        result.success(true);
      }
    }
    else if (call.method.equals(methodNameDispose)) {
      // this is easy - stop Flic
      if (null == this.flic2Controller) {
        // already started
        result.error(ERROR_NOT_STARTED, "Flic 2 hasn't been initialized", "Flic 2 isn't running so we can't stop it...");
      } else {
        // stop Flic 2 then
        boolean answer = this.flic2Controller.releaseFlic();
        this.flic2Controller = null;
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameStartFlic2Scan)) {
      // this is easy - start the controller scanning
      if (null == this.flic2Controller) {
        // not started so cannot scan
        result.error(ERROR_NOT_STARTED, "Flic 2 hasn't been started", "Flic 2 isn't running so we can't scan...");
      } else {
        // scan for new buttons then
        boolean answer = this.flic2Controller.startButtonScanning();
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameStopFlic2Scan)) {
      // this is easy - stop the controller scanning
      if (null == this.flic2Controller) {
        // already started
        result.error(ERROR_NOT_STARTED, "Flic 2 hasn't been started", "Flic 2 isn't running so we can't stop scanning...");
      } else {
        // stop scanning for new buttons then
        boolean answer = this.flic2Controller.cancelButtonScan();
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameGetButtons)) {
      // just get our buttons registered
      if (null == this.flic2Controller) {
        // already started
        result.error(ERROR_NOT_STARTED, "Flic 2 hasn't been started", "Flic 2 isn't running so we can't get buttons...");
      } else {
        // so we can get all our buttons, but have to translate them all to json before we return
        List<String> jsonButtons = new ArrayList<>();
        for (Flic2Button button : this.flic2Controller.getButtonsDiscovered()) {
          jsonButtons.add(ButtonToJson(button));
        }
        // return the list of buttons as nice transferable JSON
        result.success(jsonButtons);
      }
    }
    else if (call.method.equals(methodNameGetButtonsByAddr)) {
      // just get the button data for the passed address
      String buttonAddress = extractStringArgument(methodNameGetButtonsByAddr, "button address", call.arguments(), result);
      if (buttonAddress != null) {
        // so all's well, return the button data from this as success
        Flic2Button button = this.flic2Controller.getButtonForAddress(buttonAddress);
        if (null == button) {
          // not found, which is success returning nothing
          result.success("");
        } else {
          // else return the button as JSON
          result.success(ButtonToJson(button));
        }
      }
    }
    else if (call.method.equals(methodNameStartListenToFlic2)) {
      // start listening for the button - the arg will be the uid of the button hopefully
      String buttonUuid = extractStringArgument(methodNameStartListenToFlic2, "button UUID", call.arguments(), result);
      if (buttonUuid != null) {
        // so all's well, lets listen to the button at this UUID
        boolean answer = this.flic2Controller.listenToButton(buttonUuid);
        // and return from this as success
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameStopListenToFlic2)) {
      // stop listening for the button - the arg will be the uid of the button hopefully
      String buttonUuid = extractStringArgument(methodNameStopListenToFlic2, "button UUID", call.arguments(), result);
      if (buttonUuid != null) {
        // so all's well, lets get the listener ID and register it to call with all our results as we get them
        boolean answer = this.flic2Controller.stopListeningToButton(buttonUuid);
        // and return from this as success
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameConnectButton)) {
      // connect to the specified button
      String buttonUuid = extractStringArgument(methodNameConnectButton, "button UUID", call.arguments(), result);
      if (buttonUuid != null) {
        // so all's well, lets listen to the button at this UUID
        boolean answer = this.flic2Controller.connectButton(buttonUuid);
        // and return from this as success
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameDisconnectButton)) {
      // disconnect the button - the arg will be the uid of the button hopefully
      String buttonUuid = extractStringArgument(methodNameDisconnectButton, "button UUID", call.arguments(), result);
      if (buttonUuid != null) {
        // so all's well, lets get the listener ID and register it to call with all our results as we get them
        boolean answer = this.flic2Controller.disconnectButton(buttonUuid);
        // and return from this as success
        result.success(answer);
      }
    }
    else if (call.method.equals(methodNameForgetButton)) {
      // forget the button - the arg will be the uid of the button hopefully
      String buttonUuid = extractStringArgument(methodNameForgetButton, "button UUID", call.arguments(), result);
      if (buttonUuid != null) {
        // so all's well, lets forget this button then please
        boolean answer = this.flic2Controller.forgetButton(buttonUuid);
        // and return from this as success
        result.success(answer);
      }
    }
    else{
      result.notImplemented();
    }
  }
  
  private final Flic2Controller.ButtonCallback flic2Callback = new Flic2Controller.ButtonCallback() {
    @Override
    public void onPairedButtonFound(Flic2Button button) {
      // inform listeners of this class of this function
      informListeners(METHOD_FLIC2_DISCOVER_PAIRED, ButtonToJson(button));
    }
    @Override
    public void onButtonFound(Flic2Button button) {
      informListeners(METHOD_FLIC2_FOUND, ButtonToJson(button));
    }
    @Override
    public void onButtonConnected() {
      informListeners(METHOD_FLIC2_CONNECTED, null);
    }
    @Override
    public void onButtonDiscovered(String buttonAddress) {
      informListeners(METHOD_FLIC2_DISCOVERED, buttonAddress);
    }
    @Override
    public void onButtonScanningStarted() {
      informListeners(METHOD_FLIC2_SCANNING, null);
    }
    @Override
    public void onButtonScanningStopped() {
      informListeners(METHOD_FLIC2_SCAN_COMPLETE, null);
    }
    @Override
    public void onError(String error) {
      informListeners(METHOD_FLIC2_ERROR, error);
    }
    @Override
    public void onButtonClicked(Flic2Button button, boolean wasQueued, boolean lastQueued, long timestamp, boolean isSingleClick, boolean isDoubleClick, boolean isHold) {
      // convert all this complex and bulky data to a single object to pass back
      final String jsonData = "{" +
              "\"wasQueued\":" + wasQueued + "," +
              "\"clickAge\":" + (wasQueued ? button.getReadyTimestamp() - timestamp : 0) + "," +
              "\"lastQueued\":" + lastQueued + "," +
              "\"timestamp\":" + timestamp + "," +
              "\"isSingleClick\":" + isSingleClick + "," +
              "\"isDoubleClick\":" + isDoubleClick + "," +
              "\"isHold\":" + isHold + "," +
              "\"button\":" + ButtonToJson(button) +
              "}";
      // and send back
      informListeners(METHOD_FLIC2_CLICK, jsonData);
    }
  };

  private void informListeners(int methodId, String callbackData) {
    if (null != channel) {
      // call the method on the channel to inform listeners of this operation
      Map<String, Object> args = new HashMap<>();
      args.put("method", methodId);
      args.put("data", callbackData);
      // Send some value to callback
      channel.invokeMethod(methodNameCallback, args);
    }
  }
}
