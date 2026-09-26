#import <Flutter/Flutter.h>
#import "Flic2ControllerListener.h"

@ import flic2lib;

@interface Flic2Controller : NSObject<FLICButtonDelegate, FLICManagerDelegate>
- (id)initWithListener:(id<Flic2ControllerListener>)callback;
- (void)dispose;

- (Boolean)startButtonScanning;
- (Boolean)stopButtonScanning;
- (NSArray<FLICButton*>*)getFlic2Buttons;
- (FLICButton*)getButtonForAddress: (NSString*)address;
- (Boolean)listenToButton: (NSString*)buttonUuid;
- (Boolean)stopListeningToButton: (NSString*)buttonUuid;
- (Boolean)connectButton: (NSString*)buttonUuid;
- (Boolean)disconnectButton: (NSString*)buttonUuid;
- (Boolean)forgetButton: (NSString*)buttonUuid;
@end
