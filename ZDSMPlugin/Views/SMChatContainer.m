//
//  SMChatContainer.m
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 16/08/2016.
//  Copyright © 2016 ScreenMeet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SMChatContainer.h"
#import "SMToast.h"

@interface SMChatContainer () <ScreenMeetToastDelegate>

@property (assign, nonatomic) BOOL         hasFlippedBGImage;
@property (assign, nonatomic) CGFloat     calculatedHeight;
@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation SMChatContainer

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

- (void)commonInit
{
    self.messageQueue                    = [[NSMutableArray alloc] init];

    self.layer.cornerRadius              = 10.0f;
    self.backgroundColor                 = [UIColor clearColor];
    self.hidden                          = YES;
    self.alpha                           = 0.0f;

    self.backgroundImageView             = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chat_box"] resizableImageWithCapInsets:UIEdgeInsetsMake(18.0f, 18.0f, 18.0f, 18.0f)]];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;

    CGRect frame                         = self.bounds;

    frame.origin.x                       -= 8.0f;
    frame.size.width                     += 12.0f;

    self.backgroundImageView.frame       = frame;

    [self addSubview:self.backgroundImageView];
}

#pragma mark - Private Methods

- (void)processMessageQueue:(SMToast *)message
{
    [self.messageQueue addObject:message];
    
    [self updateMessageQueueUI];
}

- (void)updateMessageQueueUI
{
    if (self.messageQueue.count == 0) {
        [UIView animateWithDuration:1.0f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                self.hidden = YES;
            }
        }];
    } else {
        
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        }];
        
        
        __block CGFloat offset = 0.0f;
        [self.messageQueue enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                // get the current object from the queue
                SMToast *aToast = obj;

                CGRect tFrame           = aToast.frame;

                tFrame.origin.y         = offset;// calculation of the position

                offset                  += tFrame.size.height;

                CGRect frame            = self.frame;
                frame.size.height       = self.calculatedHeight;

                CGRect bgFrame          = self.backgroundImageView.frame;
                bgFrame.size.height     = self.calculatedHeight;
                
                CGAffineTransform transform = self.backgroundImageView.transform;
                
                if (self.widget.willFlipContainer) {
                    CGFloat widgetBottom = (self.widget.frame.origin.y + self.widget.frame.size.height);
                    frame.origin.y       = widgetBottom - frame.size.height;
                    if (!self.hasFlippedBGImage) {
                        self.hasFlippedBGImage = YES;
                        self.backgroundImageView.transform = CGAffineTransformScale(transform, 1, -1);
                    }
                } else {
                    if (self.hasFlippedBGImage) {
                        self.hasFlippedBGImage = NO;
                        self.backgroundImageView.transform = CGAffineTransformScale(transform, 1, -1);
                    }
                }
                
                // perform the animation back in the main queue
                // this will cause a crash if not performed this way since we are using enumaration blocks
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        aToast.frame                   = tFrame;
                        self.frame                     = frame;
                        self.backgroundImageView.frame = bgFrame;
                    }];
                });
            }
        }];
    }
}

#pragma mark - Public Methods

- (void)addStackableToastMessage:(NSString *)message
{
    SMToast *aToast               = [[SMToast alloc] initWithMessage:message];
    aToast.delegate                       = self;
    
    // show to a view with a reference
    // the reference will be used for the custom UI
    [aToast showToastToView:self from:self];
    
    self.calculatedHeight += aToast.frame.size.height;
    
    // process the message queue
    [self processMessageQueue:aToast];
}

#pragma mark - ScreenMeetToast Delegate

- (void)SMToastWillBeRemovedFromView:(SMToast *)screenMeetToast
{
    self.calculatedHeight -= screenMeetToast.frame.size.height;
    
    // remove the object from the queue
    [self.messageQueue removeObject:screenMeetToast];
    
    [self updateMessageQueueUI];
}

- (void)SMToastWasRemovedFromView:(SMToast *)screenMeetToast
{
}

@end
