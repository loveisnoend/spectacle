#import "SpectacleWindowPositionManager.h"
#import "SpectacleScreenDetection.h"
#import "SpectacleUtilities.h"
#import "SpectacleConstants.h"
#import <ZeroKit/ZeroKitAccessibilityElement.h>

@interface ZeroKitAccessibilityElement (Private)
@property(readwrite) AXUIElementRef element;
@end

@interface AccessibilityWindow : ZeroKitAccessibilityElement {
    CGRect _frameCache;
}
@property CGRect frame;
+ (AccessibilityWindow *)withElement:(AXUIElementRef)element;
@end

#pragma mark -

@interface SpectacleWindowPositionManager (SpectacleWindowPositionManagerPrivate)

- (AccessibilityWindow *)frontMostWindow;

#pragma mark -

- (void)moveWindowRect: (CGRect)windowRect frameOfScreen: (CGRect)frameOfScreen visibleFrameOfScreen: (CGRect)visibleFrameOfScreen frontMostWindowElement: (AccessibilityWindow *)frontMostWindowElement action: (SpectacleWindowAction)action;

#pragma mark -

- (CGRect)recalculateWindowRect:(AccessibilityWindow *)window frameOfScreen: (CGRect)frameOfScreen visibleFrameOfScreen: (CGRect)visibleFrameOfScreen action: (SpectacleWindowAction)action;

@end

#pragma mark -

@implementation SpectacleWindowPositionManager

static SpectacleWindowPositionManager *sharedInstance = nil;

+ (id)allocWithZone: (NSZone *)zone {
    return nil;
}

+ (SpectacleWindowPositionManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    return sharedInstance;
}

#pragma mark -

- (void)moveFrontMostWindowWithAction: (SpectacleWindowAction)action {
    [self moveWindow:[self frontMostWindow] withAction:action];
}
- (void)moveWindow:(AccessibilityWindow *)window withAction: (SpectacleWindowAction)action {
    CGRect frontMostWindowRect = window.frame;
    CGRect previousRect = CGRectNull;
    NSScreen *screenOfDisplay = [SpectacleScreenDetection screenWithAction: action andRect: frontMostWindowRect];
    CGRect frameOfScreen = CGRectNull;
    CGRect visibleFrameOfScreen = CGRectNull;

    NSScreen *mainScreen = [NSScreen mainScreen];
    if (screenOfDisplay && ![screenOfDisplay isEqual:mainScreen]) {
        NSRect mainScreenFrame = [mainScreen frame];
        frameOfScreen = NSRectToCGRect([screenOfDisplay frame]);
        visibleFrameOfScreen = NSRectToCGRect([screenOfDisplay visibleFrame]);
        if(visibleFrameOfScreen.origin.y < 0) {
            frameOfScreen.origin.y        = -frameOfScreen.origin.y - frameOfScreen.size.height + mainScreenFrame.size.height;
            visibleFrameOfScreen.origin.y = -visibleFrameOfScreen.origin.y - visibleFrameOfScreen.size.height + mainScreenFrame.size.height;
        }
    } else if(screenOfDisplay) {
        frameOfScreen = NSRectToCGRect([screenOfDisplay frame]);
        visibleFrameOfScreen = frameOfScreen;
        if([NSMenu menuBarVisible]) {
            CGFloat menuBarHeight = [[NSApp mainMenu] menuBarHeight];
            visibleFrameOfScreen.origin.y += menuBarHeight;
            visibleFrameOfScreen.size.height -= menuBarHeight;
        }
    }
    
    if (CGRectIsNull(frontMostWindowRect) || CGRectIsNull(frameOfScreen) || CGRectIsNull(visibleFrameOfScreen)) {
        NSBeep();
        return;
    }

    previousRect = frontMostWindowRect;
    frontMostWindowRect = [self recalculateWindowRect: window
                                        frameOfScreen: frameOfScreen
                                 visibleFrameOfScreen: visibleFrameOfScreen
                                               action: action];
    
    if (CGRectEqualToRect(previousRect, frontMostWindowRect) || CGRectIsNull(frontMostWindowRect)) {
        NSBeep();
        return;
    }
//    [self moveWindowRect: frontMostWindowRect frameOfScreen: frameOfScreen visibleFrameOfScreen: visibleFrameOfScreen frontMostWindowElement: window action: action];
}

@end

#pragma mark -

@implementation SpectacleWindowPositionManager (SpectacleWindowPositionManagerPrivate)

- (AccessibilityWindow *)frontMostWindow {
    ZeroKitAccessibilityElement *systemWideElement = [ZeroKitAccessibilityElement systemWideElement];
    ZeroKitAccessibilityElement *applicationWithFocusElement = [systemWideElement elementWithAttribute: kAXFocusedApplicationAttribute];
    AccessibilityWindow *frontMostWindowElement = nil;

    ZeroKitAccessibilityElement *tmp;
    if (applicationWithFocusElement) {
        tmp = [applicationWithFocusElement elementWithAttribute: kAXFocusedWindowAttribute];
        frontMostWindowElement = [AccessibilityWindow withElement:tmp.element];

        if (!frontMostWindowElement) {
            NSLog(@"Invalid accessibility element provided, unable to determine the size and position of the window.");
        }
    } else
        return nil;
    return frontMostWindowElement;
}

#pragma mark -

- (CGRect)rectOfWindowWithAccessibilityElement: (AccessibilityWindow *)accessibilityElement {
    CGRect result = CGRectNull;

    if (accessibilityElement) {
        CFTypeRef windowPositionValue = [accessibilityElement valueOfAttribute: kAXPositionAttribute type: kAXValueCGPointType];
        CFTypeRef windowSizeValue = [accessibilityElement valueOfAttribute: kAXSizeAttribute type: kAXValueCGSizeType];
        CGPoint windowPosition;
        CGSize windowSize;
        
        AXValueGetValue(windowPositionValue, kAXValueCGPointType, (void *)&windowPosition);
        AXValueGetValue(windowSizeValue, kAXValueCGSizeType, (void *)&windowSize);
        
        result = CGRectMake(windowPosition.x, windowPosition.y, windowSize.width, windowSize.height);
    }
    
    return result;
}

#pragma mark -

- (void)moveWindowRect: (CGRect)windowRect
         frameOfScreen: (CGRect)frameOfScreen
  visibleFrameOfScreen: (CGRect)visibleFrameOfScreen
frontMostWindowElement: (AccessibilityWindow *)frontMostWindowElement
                action: (SpectacleWindowAction)action {

    frontMostWindowElement.frame = windowRect;

    CGRect movedWindowRect = frontMostWindowElement.frame;
//    NSLog(@"Resized: %@", NSStringFromRect(*(NSRect *)&movedWindowRect));

    if (!CGRectContainsRect(visibleFrameOfScreen, movedWindowRect)) {
        if (movedWindowRect.origin.x + movedWindowRect.size.width > visibleFrameOfScreen.origin.x + visibleFrameOfScreen.size.width) {
            movedWindowRect.origin.x = (visibleFrameOfScreen.origin.x + visibleFrameOfScreen.size.width) - movedWindowRect.size.width;
        } else if (movedWindowRect.origin.x < visibleFrameOfScreen.origin.x) {
            movedWindowRect.origin.x = visibleFrameOfScreen.origin.x;
        }
        
        if (movedWindowRect.origin.y + movedWindowRect.size.height > visibleFrameOfScreen.origin.y + visibleFrameOfScreen.size.height) {
            movedWindowRect.origin.y = (visibleFrameOfScreen.origin.y + visibleFrameOfScreen.size.height) - movedWindowRect.size.height;
        } else if (movedWindowRect.origin.y < visibleFrameOfScreen.origin.y) {
            movedWindowRect.origin.y = visibleFrameOfScreen.origin.y;
        }
       frontMostWindowElement.frame = movedWindowRect;
    }
}

#pragma mark -

- (CGRect)recalculateWindowRect: (AccessibilityWindow *)windowToMove
                  frameOfScreen: (CGRect)frameOfScreen
           visibleFrameOfScreen: (CGRect)visibleFrameOfScreen
                         action: (SpectacleWindowAction)action {
    CGRect windowRect = windowToMove.frame;
    Boolean canChangeSize;
    AXUIElementIsAttributeSettable(windowToMove.element, (CFStringRef)kAXSizeAttribute, &canChangeSize);
    if(!canChangeSize || !windowToMove)
        return CGRectNull;

    CGFloat splitFactor = 0.6;
    CGFloat xSplit = floor(visibleFrameOfScreen.size.width*splitFactor);

    BOOL switchingSides = (action == SpectacleWindowActionRightHalf && WindowIsLeftAligned(windowToMove.frame, splitFactor, visibleFrameOfScreen)) || (action == SpectacleWindowActionLeftHalf && WindowIsRightAligned(windowToMove.frame, splitFactor, visibleFrameOfScreen));

    windowRect.origin.y = visibleFrameOfScreen.origin.y;
    if (action == SpectacleWindowActionRightHalf) {
        windowRect.origin.x = visibleFrameOfScreen.origin.x + xSplit;
        windowRect.size.width = floor(visibleFrameOfScreen.size.width * (1.0 - splitFactor));
    } else if(action == SpectacleWindowActionLeftHalf) {
        windowRect.origin.x = visibleFrameOfScreen.origin.x;
        windowRect.size.width = xSplit;
    }

    if ((action == SpectacleWindowActionLeftHalf) || (action == SpectacleWindowActionRightHalf)) {
        windowRect.size.height = visibleFrameOfScreen.size.height;

        // Get the list of windows existing in this half
        NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
        CFArrayRef cfWindows = NULL;

        NSMutableArray *involvedWindows = [NSMutableArray array];
        NSMutableArray *windowsToFix = [NSMutableArray array];
        AXUIElementRef appEl;

        NSNumber *hidden = nil;
        for(NSRunningApplication *app in apps) {
            if([app.bundleIdentifier isEqualToString:@"com.apple.dashboard.client"])
                continue;

            appEl = AXUIElementCreateApplication([app processIdentifier]);
            AXUIElementCopyAttributeValue(appEl, kAXHiddenAttribute, (CFTypeRef *)&hidden);
            if([hidden boolValue])
                continue;
            AXUIElementCopyAttributeValue(appEl, kAXWindowsAttribute, (CFTypeRef*)&cfWindows);
            NSArray *windows = (id)cfWindows;
            if([windows count] == 0)
                continue;
            for(id win_ in windows) {
                AXUIElementRef win = (AXUIElementRef)win_;
                AXUIElementCopyAttributeValue(win, kAXMinimizedAttribute, (CFTypeRef *)&hidden);
                AccessibilityWindow *window = [AccessibilityWindow withElement:win];
                if([hidden boolValue] || CGRectEqualToRect(windowToMove.frame, window.frame))
//                   || (CFEqual(win, windowToMove.element)
//                                          && [app isEqual:[[NSWorkspace sharedWorkspace] frontmostApplication]]))
                    continue;

                CGRect f = window.frame;
                if((action == SpectacleWindowActionLeftHalf && WindowIsRightAligned(f, splitFactor, visibleFrameOfScreen))
                 ||(action == SpectacleWindowActionRightHalf && WindowIsLeftAligned(f, splitFactor, visibleFrameOfScreen))) {
                    [windowsToFix addObject:window];
                }
                else if((action == SpectacleWindowActionLeftHalf  && WindowIsLeftAligned(f, splitFactor, visibleFrameOfScreen))
                      ||(action == SpectacleWindowActionRightHalf && WindowIsRightAligned(f, splitFactor, visibleFrameOfScreen))) {
                    [involvedWindows addObject:window];
                }
            }
        }
        if([involvedWindows count] > 0) {
            [involvedWindows sortUsingComparator:^NSComparisonResult(AccessibilityWindow *obj1, AccessibilityWindow *obj2) {
                return obj1.frame.origin.y > obj2.frame.origin.y ? NSOrderedDescending : NSOrderedAscending;
            }];

            windowRect.size.height /= [involvedWindows count]+1;
            CGRect rect;
            int i = 1;
            for(AccessibilityWindow *window in involvedWindows) {
                rect = windowRect;
                rect.origin.y += i * rect.size.height;
                window.frame = rect;
                ++i;
            }
        }
        [self moveWindowRect: windowRect frameOfScreen: frameOfScreen visibleFrameOfScreen: visibleFrameOfScreen frontMostWindowElement: windowToMove action: action];

        if(switchingSides && [windowsToFix count] > 0) {
            [windowsToFix sortUsingComparator:^NSComparisonResult(AccessibilityWindow *obj1, AccessibilityWindow *obj2) {
                return obj1.frame.origin.y > obj2.frame.origin.y ? NSOrderedDescending : NSOrderedAscending;
            }];
            [self recalculateWindowRect:[windowsToFix objectAtIndex:0]
                          frameOfScreen:frameOfScreen
                   visibleFrameOfScreen:visibleFrameOfScreen
                                 action:action == SpectacleWindowActionLeftHalf ? SpectacleWindowActionRightHalf : SpectacleWindowActionLeftHalf];
        }
        return windowRect;
  } else if(action == SpectacleWindowActionFullscreen)
        windowRect = visibleFrameOfScreen;
    else if(MovingToNextOrPreviousDisplay(action)) {
        NSScreen *windowScreen = [SpectacleScreenDetection screenWithAction:SpectacleWindowActionFullscreen andRect:windowToMove.frame];
        NSRect visibleFrame = [windowScreen visibleFrame];
        CGFloat windowScrXSplit = floor(visibleFrame.size.width*splitFactor);
        return [self recalculateWindowRect:windowToMove
                             frameOfScreen:frameOfScreen
                      visibleFrameOfScreen:visibleFrameOfScreen
                                    action:(windowToMove.frame.origin.x >= windowScrXSplit) ? SpectacleWindowActionRightHalf : SpectacleWindowActionLeftHalf];
    }
    
    [self moveWindowRect: windowRect frameOfScreen: frameOfScreen visibleFrameOfScreen: visibleFrameOfScreen frontMostWindowElement: windowToMove action: action];
    return windowRect;
}

@end

@implementation AccessibilityWindow
@dynamic frame;
+ (AccessibilityWindow *)withElement:(AXUIElementRef)element {
    return [[[self alloc] initWithElement:element] autorelease];
}
- (id)initWithElement:(AXUIElementRef)element {
    if(!(self = [self init]))
        return nil;
    self.element = element;
    return self;
}
- (id)init {
    if(!(self = [super init]))
        return nil;
    _frameCache = CGRectNull;
    return self;
}
- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && CFEqual([(AccessibilityWindow *)object element], self.element);
}
- (CGRect)frame {
    if(!CGRectIsNull(_frameCache))
        return _frameCache;
    CFTypeRef windowPositionValue = [self valueOfAttribute: kAXPositionAttribute type: kAXValueCGPointType];
    CFTypeRef windowSizeValue = [self valueOfAttribute: kAXSizeAttribute type: kAXValueCGSizeType];
    CGPoint windowPosition;
    CGSize windowSize;

    AXValueGetValue(windowPositionValue, kAXValueCGPointType, (void *)&windowPosition);
    AXValueGetValue(windowSizeValue, kAXValueCGSizeType, (void *)&windowSize);

    return CGRectMake(windowPosition.x, windowPosition.y, windowSize.width, windowSize.height);
}
- (void)setFrame: (CGRect)windowRect {
    _frameCache = CGRectNull;
    AXValueRef windowRectPositionRef = AXValueCreate(kAXValueCGPointType, (const void *)&windowRect.origin);
    AXValueRef windowRectSizeRef = AXValueCreate(kAXValueCGSizeType, (const void *)&windowRect.size);
//    NSLog(@">> Sizing: %@", NSStringFromRect(*(NSRect *)&windowRect));
    [self setValue: windowRectPositionRef forAttribute: kAXPositionAttribute];
    [self setValue: windowRectSizeRef forAttribute: kAXSizeAttribute];
    //    [self setValue: windowRectPositionRef forAttribute: kAXPositionAttribute];
    //    [self setValue: windowRectSizeRef forAttribute: kAXSizeAttribute];
}
@end
