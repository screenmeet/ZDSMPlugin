//
//  ScreenMeetChatWidget.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 14/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScreenMeetChatWidget.h"
#import "ScreenMeetToast.h"
#import "ScreenMeetChatContainer.h"
#import "ScreenMeetManager.h"

#define kDefaultFrame           CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)
#define kDefaultFlipThreshold   0.75

@interface ScreenMeetChatWidget ()

@property (strong, nonatomic) UIButton                *actionButton;
@property (strong, nonatomic) UIImageView             *widgetImageView;
@property (strong, nonatomic) ScreenMeetChatContainer *chatContainer;

@property (assign, nonatomic) BOOL wasDragged;

@property (assign, nonatomic) CGFloat offset;

@property (assign, nonatomic) BOOL isActive;

@end

@implementation ScreenMeetChatWidget

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)dealloc
{
    [self.actionButton removeTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton removeTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}

#pragma mark - Private Methods

- (void)commonInit
{
    CGRect frame = kDefaultFrame;
    
    if (self.frame.size.height != 0.0f || self.frame.size.width != 0.0f) {
        frame.size = self.frame.size;
    } else {
        self.frame = frame;
    }
    
    self.widgetImageView             = [[UIImageView alloc] init];
    self.widgetImageView.frame       = self.bounds;
    self.widgetImageView.contentMode = UIViewContentModeCenter;

    [self addSubview:self.widgetImageView];
    
    self.actionButton = [[UIButton alloc] initWithFrame:frame];
    
    // listener events for the drag
    [self.actionButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton addTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [self addSubview:self.actionButton];
    
    // set UI
    [self showDefaultUI];
    
    self.alpha  = 0.0f;
    self.hidden = YES;
    
    self.willFlipContainer = self.frame.origin.y >= ([UIScreen mainScreen].bounds.size.height * kDefaultFlipThreshold);
}

- (void)dragMoving:(UIControl *)control withEvent:(UIEvent *)event
{
    // set flag to eliminate false positives
    self.wasDragged = YES;
    
    // calculate the position for the touch event and adjust the current center
    // only allow vertical movement
    CGPoint movement = [[[event allTouches] anyObject] locationInView:self.superview];
    
    CGFloat threshold = self.frame.size.height;
    
    if (movement.y > threshold && movement.y < ([UIScreen mainScreen].bounds.size.height - threshold)) {
        self.center = CGPointMake(self.center.x, movement.y);
    }
    
    self.willFlipContainer = self.frame.origin.y >= [UIScreen mainScreen].bounds.size.height * kDefaultFlipThreshold;
    
    [self updateChatContainerFrame];
}

- (void)updateChatContainerFrame {
    
    if (self.chatContainer) {
        CGRect frame             = self.chatContainer.frame;
        
        if (self.willFlipContainer) {
            frame.origin.y           = self.frame.origin.y + self.frame.size.height - self.chatContainer.frame.size.height;
        } else {
            frame.origin.y           = self.frame.origin.y;
        }
        
        self.chatContainer.frame = frame;
    }
}

- (void)actionButtonWasPressed:(UIButton *)button
{
    if (self.wasDragged) {
        // don't trigger since it was a false positive
        // the message came from an event from drag
        // reset flag
        self.wasDragged = NO;
    } else {
        [self activateChat];
    }
}

#pragma mark - Public Methods

- (void)updateUI
{
    if ([[ScreenMeetManager sharedManager] isStreaming]) {
        [self showStreamingUI];
    } else if (self.isLive) {
        [self showLiveUI];
    } else {
        [self showDefaultUI];
    }
}

- (void)showDefaultUI
{
    [self.actionButton setTitle:@"•••" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.widgetImageView.image  = nil;
    
    self.backgroundColor        = [UIColor whiteColor];
    self.layer.borderColor      = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth      = 2.0f;
}

- (void)showLiveUI
{
    // same as default UI.
    [self showDefaultUI];
}

- (void)showStreamingUI
{
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.widgetImageView.image  = [UIImage imageNamed:@"icon_widget"];
    
    self.backgroundColor        = [UIColor redColor];
    self.layer.borderColor      = [UIColor whiteColor].CGColor;
    self.layer.borderWidth      = 2.0f;
}

- (void)showWidget
{
    if (self.hidden) {
        // just to make sure
        self.alpha  = 0.0f;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
//            [self delayLine:0 andMaxCount:10];
        }];

        if (!self.chatContainer) {
            CGFloat originX           = self.frame.origin.x + self.frame.size.width + 10.0f;
            self.chatContainer        = [[ScreenMeetChatContainer alloc] initWithFrame:CGRectMake(originX, self.frame.origin.y, [UIScreen mainScreen].bounds.size.width - originX - 10.0f, 100.0f)];
            
            [self.superview addSubview:self.chatContainer];
        }
        
        [self.superview bringSubviewToFront:self.chatContainer];
        self.chatContainer.widget = self;
        self.isActive = YES;
    }
    
    [self updateUI];
}

// for testing purposes
- (void)delayLine:(NSInteger)iteration andMaxCount:(NSInteger)maxCount
{
    if (iteration < maxCount) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self addStackableToastMessage:[NSString stringWithFormat:@"A sample toast:%ld", iteration+1]];
            [self delayLine:(iteration+1) andMaxCount:maxCount];
        });
    }
}

- (void)hideWidget
{
    if (!self.hidden) {
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            
            self.isActive = NO;
        }];
    }
}

- (void)activateChat
{
    [ScreenMeetManager presentViewControllerFromWindowRootViewController:[[UINavigationController alloc] initWithRootViewController:(UIViewController *)[[ScreenMeetManager sharedManager] messagesVC]] animated:YES completion:^{
        [self hideWidget];
    }];
}

- (void)endChat
{
    [self hideWidget];
}

- (void)addStackableToastMessage:(NSString *)message
{
    [self.chatContainer addStackableToastMessage:message];
}

#pragma mark - Orientation Change

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // Obtaining the current device orientation
    CGPoint center = self.center;
    center.y       = [UIScreen mainScreen].bounds.size.height/2;
    self.center    = center;
}

#pragma mark - Keyboard Notifications

// Called when the UIKeyboardWillShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize      = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect aRect       = [UIScreen mainScreen].bounds;
    
    CGFloat widgetBottom = CGRectGetMaxY(self.frame);
    CGFloat widgetBottomSpace = aRect.size.height - widgetBottom;
    
    if (widgetBottom > (aRect.size.height - kbSize.height)) {
        // always set widget position a little higher then keyboard
        self.offset           = kbSize.height - widgetBottomSpace;
        self.center           = CGPointMake(self.center.x, self.center.y - self.offset - self.frame.size.height/2);

        [self updateChatContainerFrame];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.offset > 0.0f) {
        self.center           = CGPointMake(self.center.x, self.center.y + self.offset + self.frame.size.height/2);
        self.offset           = 0.0f;
        
        [self updateChatContainerFrame];
    }
}

@end
