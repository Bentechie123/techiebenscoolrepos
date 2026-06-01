/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


#import <UIKit/UIKit.h>

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

