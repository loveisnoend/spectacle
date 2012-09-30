#import <Foundation/Foundation.h>

typedef enum {
    SpectacleWindowActionNone = -1,
    SpectacleWindowActionFullscreen,
    SpectacleWindowActionLeftHalf,
    SpectacleWindowActionRightHalf,
    SpectacleWindowActionNextDisplay,
    SpectacleWindowActionPreviousDisplay,
} SpectacleWindowAction;

@interface SpectacleWindowPositionManager : NSObject
+ (SpectacleWindowPositionManager *)sharedManager;
- (void)moveFrontMostWindowWithAction: (SpectacleWindowAction)action;
@end
