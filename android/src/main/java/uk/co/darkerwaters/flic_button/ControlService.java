package uk.co.darkerwaters.flic_button;

import android.app.Service;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.IBinder;

import androidx.annotation.Nullable;

import java.util.ArrayList;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterCallbackInformation;

public class ControlService extends Service {
    public static final String CALLBACK_HANDLE_KEY = "FLIC_BACKGROUND_CALLBACK_HANDLE_KEY";
    public static final String CALLBACK_DISPATCHER_HANDLE_KEY = "FLIC_BACKGROUND_DISPATCH_CALLBACK_HANDLE_KEY";

    private MethodChannel mBackgroundChannel;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        long callbackDispatcherHandle = intent.getLongExtra(CALLBACK_DISPATCHER_HANDLE_KEY, 0);

        AssetManager assetManager = getApplicationContext().getAssets();
        String appBundlePath = FlutterInjector.instance().flutterLoader().findAppBundlePath();
        FlutterCallbackInformation callbackInformation = FlutterCallbackInformation.lookupCallbackInformation(callbackDispatcherHandle);

        FlutterEngine flutterEngine = new FlutterEngine(this.getApplicationContext());
        flutterEngine.getDartExecutor().executeDartCallback(
                new DartExecutor.DartCallback(assetManager, appBundlePath, callbackInformation)
        );

        long callbackHandle = intent.getLongExtra(CALLBACK_HANDLE_KEY, 0);

        final ArrayList<Object> l = new ArrayList<Object>();
        l.add(callbackHandle);
        l.add("Hello, I am transferred from java to dart world");

        mBackgroundChannel.invokeMethod("", l);

        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

}
