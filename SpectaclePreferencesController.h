#import <Cocoa/Cocoa.h>
#import <ZeroKit/ZeroKit.h>

@class SpectacleHotKeyManager, SpectacleApplicationController;

@interface SpectaclePreferencesController : NSWindowController<ZeroKitHotKeyRecorderDelegate> {
    SpectacleApplicationController *myApplicationController;
    SpectacleHotKeyManager *myHotKeyManager;
    NSDictionary *myHotKeyRecorders;
    IBOutlet ZeroKitHotKeyRecorder *myMoveToFullscreenHotKeyRecorder;
    IBOutlet ZeroKitHotKeyRecorder *myMoveToLeftHotKeyRecorder;
    IBOutlet ZeroKitHotKeyRecorder *myMoveToRightHotKeyRecorder;
     IBOutlet ZeroKitHotKeyRecorder *myMoveToNextDisplayHotKeyRecorder;
    IBOutlet ZeroKitHotKeyRecorder *myMoveToPreviousDisplayHotKeyRecorder;
    IBOutlet NSButton *myLoginItemEnabled;
    IBOutlet NSPopUpButton *myStatusItemEnabled;
}

- (id)initWithApplicationController: (SpectacleApplicationController *)applicationController;

#pragma mark -

- (IBAction)toggleWindow: (id)sender;

#pragma mark -

- (IBAction)hideWindow: (id)sender;

#pragma mark -

- (IBAction)toggleLoginItem: (id)sender;

- (IBAction)toggleStatusItem: (id)sender;

@end
