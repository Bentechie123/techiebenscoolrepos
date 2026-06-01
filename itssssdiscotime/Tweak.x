/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

static UIView *discoView = nil;

static void updateColor() {
    if (!discoView) return;
    CGFloat r = (arc4random() % 255) / 255.0;
    CGFloat g = (arc4random() % 255) / 255.0;
    CGFloat b = (arc4random() % 255) / 255.0;
    discoView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

%hook SBLockScreenViewController

- (void)viewDidLoad {
    %orig;
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        discoView = [[UIView alloc] initWithFrame:window.bounds];
        discoView.alpha = 0.4;
        discoView.userInteractionEnabled = NO;
        [window addSubview:discoView];
        
        [NSTimer scheduledTimerWithTimeInterval:0.15
            target:[NSBlockOperation blockOperationWithBlock:^{ updateColor(); }]
            selector:@selector(main)
            userInfo:nil
            repeats:YES];
    });
}

%end
static UIView *discoView = nil;
static NSTimer *discoTimer = nil;
static BOOL discoEnabled = YES;

static void startDisco() {
    if (discoView) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    discoView = [[UIView alloc] initWithFrame:window.bounds];
    discoView.alpha = 0.3;
    discoView.userInteractionEnabled = NO;
    [window addSubview:discoView];
    
    discoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
        target:[NSBlockOperation blockOperationWithBlock:^{
            if (!discoEnabled) return;
            CGFloat r = (arc4random() % 255) / 255.0;
            CGFloat g = (arc4random() % 255) / 255.0;
            CGFloat b = (arc4random() % 255) / 255.0;
            discoView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }]
        selector:@selector(main)
        userInfo:nil
        repeats:YES];
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    startDisco();
}

%end
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

static UIView *discoView = nil;
static NSTimer *discoTimer = nil;
static BOOL discoEnabled;

static void loadPrefs() {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.techieben.itssssdiscotime.plist"];
    discoEnabled = prefs ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
}

static void startDisco() {
    if (discoView) return;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    discoView = [[UIView alloc] initWithFrame:window.bounds];
    discoView.alpha = 0.3;
    discoView.userInteractionEnabled = NO;
    [window addSubview:discoView];
    
    discoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
        target:[NSBlockOperation blockOperationWithBlock:^{
            if (!discoEnabled) {
                discoView.hidden = YES;
                return;
            }
            discoView.hidden = NO;
            CGFloat r = (arc4random() % 255) / 255.0;
            CGFloat g = (arc4random() % 255) / 255.0;
            CGFloat b = (arc4random() % 255) / 255.0;
            discoView.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        }]
        selector:@selector(main)
        userInfo:nil
        repeats:YES];
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    loadPrefs();
    startDisco();
}
%end

%ctor {
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)loadPrefs,
        CFSTR("com.techieben.itssssdiscotime/prefschanged"),
        NULL,
        CFNotificationSuspensionBehaviorCoalesce
    );
}
