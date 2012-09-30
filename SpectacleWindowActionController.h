#import <Foundation/Foundation.h>

@class SpectacleWindowPositionManager, SpectacleHotKeyManager;

@interface SpectacleWindowActionController : NSObject {
    SpectacleWindowPositionManager *myWindowPositionManager;
    SpectacleHotKeyManager *myHotKeyManager;
}

- (void)registerHotKeys;


#pragma mark -

- (IBAction)moveFrontMostWindowToFullscreen:(id)sender;

#pragma mark -

- (IBAction)moveFrontMostWindowToLeftHalf:(id)sender;

- (IBAction)moveFrontMostWindowToRightHalf:(id)sender;

- (IBAction)moveFrontMostWindowToNextDisplay:(id)sender;

- (IBAction)moveFrontMostWindowToPreviousDisplay:(id)sender;

@end
