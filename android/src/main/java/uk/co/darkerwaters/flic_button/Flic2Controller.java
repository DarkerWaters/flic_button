package uk.co.darkerwaters.flic_button;

import android.content.Context;
import android.os.Handler;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flic.flic2libandroid.Flic2Button;
import io.flic.flic2libandroid.Flic2ButtonListener;
import io.flic.flic2libandroid.Flic2Manager;
import io.flic.flic2libandroid.Flic2ScanCallback;

public class Flic2Controller {
    // keep the buttons so we can call functions on them later from flutter (via UUID)
    private final Map<String, Flic2Button> buttonsDiscovered = new HashMap<>();

    private final ButtonCallback callback;

    public interface ButtonCallback {
        void onPairedButtonFound(Flic2Button button);
        void onButtonFound(Flic2Button button);
        void onButtonConnected();
        void onButtonDiscovered(String buttonAddress);
        void onButtonScanningStarted();
        void onButtonScanningStopped();
        void onButtonClicked(Flic2Button button, boolean wasQueued, boolean lastQueued, long timestamp, boolean isSingleClick, boolean isDoubleClick, boolean isHold);
        void onError(String error);
    }

    public Flic2Controller(Context context, ButtonCallback callback) {
        // one callback to inform per manager
        this.callback = callback;
        // initialise the manager, don't need to remember it as we can just get it later
        Flic2Manager.initAndGetInstance(context, new Handler());
    }

    public boolean startButtonScanning() {
        // cancel any previous scan
        cancelButtonScan();
        // and start a new one
        callback.onButtonScanningStarted();
        Flic2Manager.getInstance().startScan(new Flic2ScanCallback() {
            @Override
            public void onDiscoveredAlreadyPairedButton(Flic2Button button) {
                // Found an already paired button
                storeButtonData(button);
                // and inform the caller of this state
                callback.onPairedButtonFound(button);
            }
            @Override
            public void onDiscovered(String bdAddr) {
                // Found Flic2, now connecting, inform the caller of this state
                callback.onButtonDiscovered(bdAddr);
            }
            @Override
            public void onConnected() {
                // connecting to a flic button
                callback.onButtonConnected();
            }
            @Override
            public void onComplete(int result, int subCode, Flic2Button button) {
                callback.onButtonScanningStopped();
                if (result == Flic2ScanCallback.RESULT_SUCCESS) {
                    // The button object can now be used, store this
                    storeButtonData(button);
                    // and inform the caller of this state
                    callback.onButtonFound(button);
                } else {
                    callback.onError(String.format("Internal FLic2 Scan Error with result %d, subCode: %d", result, subCode));
                }
            }
        });
        return true;
    }

    public boolean cancelButtonScan() {
        // cancel any scanning in progress
        callback.onButtonScanningStopped();
        try {
            Flic2Manager manager = Flic2Manager.getInstance();
            if (null != manager) {
                manager.stopScan();
                return true;
            }
        }
        catch (Exception e) {
            callback.onError("Failed to stop scan while releasing flick " + e.getMessage());
        }
        return false;
    }

    private void storeButtonData(Flic2Button button) {
        // store this data for later
        synchronized (buttonsDiscovered) {
            buttonsDiscovered.put(button.getUuid(), button);
        }
    }
    
    public List<Flic2Button> getButtonsDiscovered() {
        List<Flic2Button> buttons = Flic2Manager.getInstance().getButtons();
        for (Flic2Button button : buttons) {
            // while we are here, remember the data in case they want to listen to it
            storeButtonData(button);
        }
        return buttons;
    }
    
    public Flic2Button getButtonForAddress(String buttonAddress) {
        return Flic2Manager.getInstance().getButtonByBdAddr(buttonAddress);
    }

    public boolean connectButton(String buttonUuid) {
        // get the button to listen to from our map and then listen to it
        Flic2Button button;
        synchronized (buttonsDiscovered) {
            button = buttonsDiscovered.get(buttonUuid);
        }
        if (null == button) {
            callback.onError("Cannot connect a button as don't recognise the UUID " + buttonUuid);
            return false;
        } else {
            // and connect to the button
            button.connect();
            return true;
        }
    }

    public boolean disconnectButton(String buttonUuid) {
        // get the button to listen to from our map and then listen to it
        Flic2Button button;
        synchronized (buttonsDiscovered) {
            button = buttonsDiscovered.get(buttonUuid);
        }
        if (null == button) {
            callback.onError("Cannot disconnect a button as don't recognise the UUID " + buttonUuid);
            return false;
        } else {
            // and disconnect from the button
            button.disconnectOrAbortPendingConnection();
            return true;
        }
    }

    public boolean forgetButton(String buttonUuid) {
        // get the button to forget
        Flic2Button button;
        synchronized (buttonsDiscovered) {
            button = buttonsDiscovered.get(buttonUuid);
        }
        if (null == button) {
            callback.onError("Cannot forget a button as don't recognise the UUID " + buttonUuid);
            return false;
        } else {
            // and forget this button
            Flic2Manager.getInstance().forgetButton(button);
            return true;
        }
    }
    
    public boolean listenToButton(String buttonUuid) {
        // get the button to listen to from our map and then listen to it
        Flic2Button button;
        synchronized (buttonsDiscovered) {
            button = buttonsDiscovered.get(buttonUuid);
        }
        if (null == button) {
            callback.onError("Cannot to listen to a button as don't recognise the UUID " + buttonUuid);
            return false;
        } else {
            if (button.getConnectionState() == Flic2Button.CONNECTION_STATE_DISCONNECTED) {
                // to listen to a button we need it connected first, let's assume the caller wants this done
                button.connect();
                // there's a function to inform the listeners of this while we are doing this ourselves
                callback.onButtonConnected();
            }
            // we might already be listening to this, try to remove it first
            button.removeListener(buttonListener);
            // and add it back in to listen to each button only once.
            button.addListener(buttonListener);
            return true;
        }
    }

    public boolean stopListeningToButton(String buttonUuid) {
        // get the button to stop listening to from our map and then listen to it
        Flic2Button button;
        synchronized (buttonsDiscovered) {
            button = buttonsDiscovered.get(buttonUuid);
        }
        if (null == button) {
            callback.onError("Cannot stop listening to a button as don't recognise the UUID " + buttonUuid);
            return false;
        } else {
            button.removeListener(buttonListener);
            return true;
        }
    }

    private final Flic2ButtonListener buttonListener = new Flic2ButtonListener() {
        @Override
        public void onButtonSingleOrDoubleClickOrHold(Flic2Button button, boolean wasQueued, boolean lastQueued, long timestamp, boolean isSingleClick, boolean isDoubleClick, boolean isHold) {
            // let the base deal
            super.onButtonSingleOrDoubleClickOrHold(button, wasQueued, lastQueued, timestamp, isSingleClick, isDoubleClick, isHold);
            // and pass this button press from Flic2 on to our application
            callback.onButtonClicked(button, wasQueued, lastQueued, timestamp, isSingleClick, isDoubleClick, isHold);
        }
    };

    public boolean releaseFlic() {
        // cancel any scanning
        cancelButtonScan();
        // release all the flic 2 listeners on the managers
        try {
            Flic2Manager manager = Flic2Manager.getInstance();
            if (null != manager) {
                // we are probably listening to buttons, stop this
                for (Flic2Button button : manager.getButtons()) {
                    try {
                        button.removeListener(buttonListener);
                    } catch (Exception e) {
                        callback.onError("Failed to remove listener on releasing flic " + e.getMessage());
                    }
                }
                return true;
            }
        }
        catch (Exception e) {
            callback.onError("Failed to destroy the flic two instance as it was not initialised " + e.getMessage());
        }
        return false;
    }
}
