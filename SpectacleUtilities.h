#import <Foundation/Foundation.h>
#import <ZeroKit/ZeroKit.h>

#define FlipVerticalOriginOfRectInRect(a, b) (b.size.height - (a.origin.y + a.size.height) + ([[NSScreen mainScreen] frame].size.height - b.size.height))

#pragma mark -

#define AreaOfRect(a) (CGFloat)(a.size.width * a.size.height)

#pragma mark -

#define RectIsLeftOfRect(a, b) ((b.origin.x - a.size.width) == a.origin.x)
#define RectIsRightOfRect(a, b) ((b.origin.x + b.size.width) == a.origin.x)
#define RectIsAboveRect(a, b) ((b.origin.y + b.size.height) == a.origin.y)
#define RectIsBelowRect(a, b) ((b.origin.y - a.size.height) == a.origin.y)

#pragma mark -

#define RectFitsInRect(a, b) ((a.size.width <= b.size.width) && (a.size.height <= b.size.height))

#pragma mark -

#define MovingToNextOrPreviousDisplay(action) ((action == SpectacleWindowActionNextDisplay) || (action == SpectacleWindowActionPreviousDisplay))

#define WindowIsLeftAligned(f, splitFactor, screenFrame) \
    ((f.origin.x == screenFrame.origin.x) \
    && (f.size.width == floor(screenFrame.size.width * splitFactor)))
#define WindowIsRightAligned(f, splitFactor, screenFrame) \
    ((f.origin.x == screenFrame.origin.x + floor(screenFrame.size.width * splitFactor)) \
    && f.size.width == floor(screenFrame.size.width * (1.0 - splitFactor)))

#pragma mark -

#define WindowRectToString(windowRect) [NSString stringWithFormat: @"(%f, %f) %fx%f", windowRect.origin.x, windowRect.origin.y, windowRect.size.width, windowRect.size.height]

#pragma mark -

@interface SpectacleUtilities : ZeroKitUtilities

+ (void)displayAccessibilityAPIAlert;

+ (void)displayRunningInBackgroundAlertWithCallback: (void (^)(BOOL, BOOL))callback;

#pragma mark -

+ (NSArray *)hotKeyNames;

#pragma mark -

+ (NSArray *)hotKeysFromDictionary: (NSDictionary *)dictionary hotKeyTarget: (id)target;

#pragma mark -

+ (ZeroKitHotKeyAction *)actionForHotKeyWithName: (NSString *)key target: (id)target;

#pragma mark -

+ (NSInteger)currentWorkspace;

@end
