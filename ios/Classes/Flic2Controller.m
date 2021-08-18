#import <Foundation/Foundation.h>
#import "Flic2Controller.h"
#import "Flic2ControllerListener.h"

@ import flic2lib;

@implementation Flic2Controller
{
    id<Flic2ControllerListener> callback;
    NSMutableDictionary* buttonsDiscovered;
}

- (id)initWithListener:(id<Flic2ControllerListener>)callback {
    if (self = [super init]) {
        self->callback = callback;
        self->buttonsDiscovered = [[NSMutableDictionary alloc] init];
        // and initialize the Flic2 singleton
        [FLICManager configureWithDelegate:self buttonDelegate:self background:YES];
    }
    return self;
    
}

- (void)dispose {
    // shut everything down
    self->callback = nil;
    self->buttonsDiscovered = nil;
    FLICManager* manager = [FLICManager sharedManager];
    // cancel any active scanning
    [manager stopScan];
    // clear us as the delegates
    [manager setDelegate:nil];
    [manager setButtonDelegate:nil];
}

- (void)manager:(nonnull FLICManager *)manager didUpdateState:(FLICManagerState)state {
    switch (state)
    {
        case FLICManagerStatePoweredOn:
            // Flic buttons can now be scanned and connected.
            NSLog(@"Bluetooth is turned on");
            break;
        case FLICManagerStatePoweredOff:
            // Bluetooth is not powered on.
            NSLog(@"Bluetooth is turned off");
            break;
        case FLICManagerStateUnsupported:
            // The framework can not run on this device.
            NSLog(@"FLICManagerStateUnsupported");
        default:
            break;
    }
}

- (void)initializeButton:(FLICButton*)button {
    // put this into our map of data then please, for later access
    [buttonsDiscovered setObject:button forKey:button.uuid];
    // setup the button properly then please
    if (button.triggerMode != FLICButtonTriggerModeClickAndDoubleClickAndHold) {
        // change the mode of the button to tell us everything please
        NSLog(@"changing button to inform about all types of button press");
        button.triggerMode = FLICButtonTriggerModeClickAndDoubleClickAndHold;
    }
}

- (void)managerDidRestoreState:(nonnull FLICManager *)manager {
    // The manager was restored and can now be used.
    for (FLICButton *button in manager.buttons) {
        // and set it up then which will also add it to our map as needed later
        [self initializeButton:button];
        // and inform any listeners of this change in state
        if (nil != self->callback) {
            // pass this to the callback then
            [self->callback onPairedButtonFound:button];
        }
    }
}

- (Boolean)startButtonScanning {
    if (nil != self->callback) {
        // pass this to the callback then
        [self->callback onButtonScanningStarted];
    }
    [[FLICManager sharedManager] scanForButtonsWithStateChangeHandler:^(FLICButtonScannerStatusEvent event) {
        // You can use these events to update your UI.
        switch (event)
        {
            case FLICButtonScannerStatusEventDiscovered:
                // discovery doesn't have the address, so let's just leave it alone here
                break;
            case FLICButtonScannerStatusEventConnected:
                // and inform any listeners of this change in state
                if (nil != self->callback) {
                    // pass this to the callback then
                    [self->callback onButtonConnected];
                }
                break;
            case FLICButtonScannerStatusEventVerified:
                break;
            case FLICButtonScannerStatusEventVerificationFailed:
                NSLog(@"The Flic verification failed.");
                break;
            default:
                break;
        }
    } completion:^(FLICButton *button, NSError *error) {
        if (nil != self->callback) {
            // pass this to the callback then
            [self->callback onButtonScanningStopped];
        }
        if (!error) {
            // Listen to all the click types then please by initializing the button here
            [self initializeButton:button];
            // and inform any listeners of this change in state
            if (nil != self->callback) {
                // pass this to the callback then
                [self->callback onButtonDiscovered:button.bluetoothAddress];
            }
        } else {
            NSLog(@"Scanner completed with error: %@", error);
            // inform any listeners of this error
            if (nil != self->callback) {
                // pass this to the callback then
                [self->callback onError:error.localizedDescription];
            }
        }
    }];
    return true;
}

- (Boolean)stopButtonScanning {
    // stop the scanning
    [[FLICManager sharedManager] stopScan];
    // this will return any active scan with an error so we don't need to send a message from here...
    return true;
}

- (NSArray<FLICButton*>*)getFlic2Buttons {
    // just return our list, but in a way that the caller cannot edit
    return [[self->buttonsDiscovered allValues] copy];
}

- (FLICButton*)getButtonForAddress: (NSString*)address {
    if (nil == address) {
        // not good
        return nil;
    }
    // find the button in the array to return
    for (FLICButton* button in [self->buttonsDiscovered allValues]) {
        if ([button.bluetoothAddress isEqualToString:address]) {
            // this is the one
            return button;
        }
    }
    // not found
    return nil;
}

- (FLICButton*)getButtonForUuid: (NSString*)buttonUuid {
    if (nil == buttonUuid) {
        // not good
        return nil;
    }
    // find the button in the array to return
    for (FLICButton* button in [self->buttonsDiscovered allValues]) {
        if ([button.uuid isEqualToString:buttonUuid]) {
            // this is the one
            return button;
        }
    }
    // not found
    return nil;
}

- (Boolean)listenToButton: (NSString*)buttonUuid {
    FLICButton* button = [self getButtonForUuid:buttonUuid];
    if (nil != button) {
        // there's no listen / don't listen in iOS but we can ask for clicks or not, so let's do that
        button.triggerMode = FLICButtonTriggerModeClickAndDoubleClickAndHold;
        return true;
    } else {
        return false;
    }
}

- (Boolean)stopListeningToButton: (NSString*)buttonUuid {
    // can't really do this, stop listening that is...
    FLICButton* button = [self getButtonForUuid:buttonUuid];
    if (nil != button) {
        // there's no listen / don't listen in iOS but we can ask for clicks or not, so let's do that
        // but it also doesn't let us stop listening to everything )O:
        //button.triggerMode = FLICButtonTriggerModeNone;
        return false;
    } else {
        return false;
    }
}

- (Boolean)connectButton: (NSString*)buttonUuid {
    FLICButton* button = [self getButtonForUuid:buttonUuid];
    if (nil != button) {
        // and connect the button
        [button connect];
        return true;
    } else {
        return false;
    }
}

- (Boolean)disconnectButton: (NSString*)buttonUuid {
    FLICButton* button = [self getButtonForUuid:buttonUuid];
    if (nil != button) {
        // and disconnect the button
        [button disconnect];
        return true;
    } else {
        return false;
    }
}

- (Boolean)forgetButton: (NSString*)buttonUuid {
    FLICButton* button = [self getButtonForUuid:buttonUuid];
    if (nil != button) {
        // and forget the button
        [[FLICManager sharedManager] forgetButton:button completion:^(NSUUID * _Nonnull uuid, NSError * _Nullable error) {
            if (!error) {
                // so we can remove this from our map of buttons
                [self->buttonsDiscovered removeObjectForKey:buttonUuid];
            } else {
                // inform any listeners of this error
                NSLog(@"Forget button failed with error: %@", error);
                if (nil != self->callback) {
                    // pass this to the callback then
                    [self->callback onError:error.localizedDescription];
                }
            }
        }];
        return true;
    } else {
        return false;
    }
}

- (void)button:(nonnull FLICButton *)button didDisconnectWithError:(NSError * _Nullable)error {
    // and inform any listeners of this problem
    if (nil != self->callback && nil != error) {
        // pass this to the callback then
        [self->callback onError:error.localizedDescription];
    }
}

- (void)button:(nonnull FLICButton *)button didFailToConnectWithError:(NSError * _Nullable)error {
    // and inform any listeners of this problem
    if (nil != self->callback && nil != error) {
        // pass this to the callback then
        [self->callback onError:error.localizedDescription];
    }
}

- (void)buttonDidConnect:(nonnull FLICButton *)button {
    // be sure to setup the button properly as it connects
    [self initializeButton:button];
    // and inform any listeners of this lovely action (just like android so can't pass the button)
    if (nil != self->callback) {
        // pass this to the callback then that we are connected
        [self->callback onButtonConnected];
    }
}

- (void)buttonIsReady:(nonnull FLICButton *)button {
    // be sure to setup the button properly as it becomes ready
    [self initializeButton:button];
    // and inform any listeners of this lovely action (acts like the android found function)
    if (nil != self->callback) {
        // pass this to the callback then that we are connected
        [self->callback onButtonFound:button];
    }
}

- (void)button:(FLICButton *)button didReceiveButtonClick:(BOOL)queued age:(NSInteger)age {
    if (nil != self->callback) {
        // pass this to the callback then
        [self->callback onButtonClicked:button wasQueued:queued at:age withClicks:1];
    }
}

- (void)button:(FLICButton *)button didReceiveButtonDoubleClick:(BOOL)queued age:(NSInteger)age {
    if (nil != self->callback) {
        // pass this to the callback then
        [self->callback onButtonClicked:button wasQueued:queued at:age withClicks:2];
    }
}

- (void)button:(FLICButton *)button didReceiveButtonHold:(BOOL)queued age:(NSInteger)age {
    if (nil != self->callback) {
        // pass this to the callback then
        [self->callback onButtonClicked:button wasQueued:queued at:age withClicks:3];
    }
}

@end
