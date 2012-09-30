#import "SpectacleWindowActionController.h"
#import "SpectacleWindowPositionManager.h"
#import "SpectacleHotKeyManager.h"
#import "SpectacleUtilities.h"

@implementation SpectacleWindowActionController

- (id)init {
    if (self = [super init]) {
        myWindowPositionManager = [SpectacleWindowPositionManager sharedManager];
        myHotKeyManager = [SpectacleHotKeyManager sharedManager];
    }
    
    return self;
}

#pragma mark -

- (void)registerHotKeys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *hotKeysFromUserDefaults = [NSMutableDictionary dictionary];
    
    for (NSString *hotKeyName in [SpectacleUtilities hotKeyNames]) {
        [hotKeysFromUserDefaults setObject: [userDefaults dataForKey: hotKeyName] forKey: hotKeyName];
    }
    
    [myHotKeyManager registerHotKeys: [SpectacleUtilities hotKeysFromDictionary: hotKeysFromUserDefaults hotKeyTarget: self]];
}

#pragma mark -

- (IBAction)moveFrontMostWindowToFullscreen: (id)sender {
    [myWindowPositionManager moveFrontMostWindowWithAction: SpectacleWindowActionFullscreen];
}

#pragma mark -

- (IBAction)moveFrontMostWindowToLeftHalf: (id)sender {
    [myWindowPositionManager moveFrontMostWindowWithAction: SpectacleWindowActionLeftHalf];
}

- (IBAction)moveFrontMostWindowToRightHalf: (id)sender {
    [myWindowPositionManager moveFrontMostWindowWithAction: SpectacleWindowActionRightHalf];
}

#pragma mark -

- (IBAction)moveFrontMostWindowToNextDisplay: (id)sender {
    [myWindowPositionManager moveFrontMostWindowWithAction: SpectacleWindowActionNextDisplay];
}

- (IBAction)moveFrontMostWindowToPreviousDisplay: (id)sender {
    [myWindowPositionManager moveFrontMostWindowWithAction: SpectacleWindowActionPreviousDisplay];
}

@end
