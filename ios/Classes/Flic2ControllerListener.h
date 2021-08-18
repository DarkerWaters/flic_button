@class FLICButton;

@protocol Flic2ControllerListener
- (void) onPairedButtonFound:(FLICButton*)button;
- (void) onButtonFound:(FLICButton*)button;
- (void) onButtonConnected;
- (void) onButtonDiscovered:(NSString*)buttonAddress;
- (void) onButtonScanningStarted;
- (void) onButtonScanningStopped;
- (void) onButtonClicked:(FLICButton*)button wasQueued:(BOOL)queued at:(NSInteger)age withClicks:(NSInteger)clicks;
- (void) onError:(NSString*)errorString;
@end
