//
//  ScreenMeetToast.m
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 15/08/2016.
//  Copyright © 2016 ScreenMeet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SMToast.h"

#define kDefaultHeight      [UIScreen mainScreen].bounds.size.height
#define kDefaultWidth       ([UIScreen mainScreen].bounds.size.width - 20.0f)
#define kDefaultFadeTime    1.0f
#define kDefaultDisplayTime 3.0f

@interface SMToast ()

@property (strong, nonatomic) UILabel     *toastLabel;
@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation SMToast

@synthesize delegate = __delegate;

- (instancetype)initWithMessage:(NSString *)message andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        self.message = message;
        [self commonInit];
    }
    return self;
}

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

#pragma mark - Class Methods

+ (id)roundCornersOnView:(id)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius
{
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView     = view;
        UIBezierPath *maskPath  = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame         = roundedView.bounds;
        maskLayer.path          = maskPath.CGPath;
        roundedView.layer.mask  = maskLayer;
        
        return roundedView;
    } else {
        return view;
    }
}

#pragma mark - Private Methods

- (void)commonInit
{
    if (self.frame.size.width == 0.0f) {
        self.frame = CGRectMake(10.0f, 44.0f, kDefaultWidth, kDefaultHeight);
    }

    self.fadeTime                         = kDefaultFadeTime;
    self.displayTime                      = kDefaultDisplayTime;
    self.alpha                            = 0.0f;

    self.backgroundColor                  = [UIColor clearColor];
    self.clipsToBounds                    = YES;

    self.backgroundView                   = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor   = [UIColor clearColor];
    self.backgroundView.alpha             = 0.30f;
    self.backgroundView.clipsToBounds     = YES;

    [self addSubview:self.backgroundView];

    self.toastIcon                        = [UIImage imageNamed:@"user_icon"];
    
    CGFloat iconWidth                     = 15.0f;

    self.iconImageView                    = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, iconWidth, iconWidth)];
    self.iconImageView.image              = self.toastIcon;

    self.iconImageView.clipsToBounds      = YES;
    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width/2;
    self.iconImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.iconImageView.layer.borderWidth  = 1.0f;
    
    [self addSubview:self.iconImageView];

    self.toastLabel                       = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 5.0f, self.frame.size.width - 45.0f, self.frame.size.height - 10.0f)];
    self.toastLabel.backgroundColor       = [UIColor clearColor];
    self.toastLabel.numberOfLines         = 0;
    self.toastLabel.lineBreakMode         = NSLineBreakByTruncatingTail;
    self.toastLabel.textColor             = [UIColor whiteColor];
    self.toastLabel.font                  = [UIFont systemFontOfSize:12.0f];
    self.toastLabel.text                  = self.message;
    
    [self addSubview:self.toastLabel];
}

- (void)fadeOut
{
    if ([self.delegate respondsToSelector:@selector(SMToastWillBeRemovedFromView:)]) {
        [self.delegate SMToastWillBeRemovedFromView:self];
    }
    
    [UIView animateWithDuration:self.fadeTime animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            // trigger delegate
            if ([self.delegate respondsToSelector:@selector(SMToastWasRemovedFromView:)]) {
                [self.delegate SMToastWasRemovedFromView:self];
            }
            
            // remove self
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Public Methods

- (void)showToastToView:(UIView *)view from:(UIView *)sourceView
{
    [self showToastToView:view from:sourceView withRoundedCornersOnTopLeft:YES topRight:YES bottomLeft:YES bottomRight:YES radius:0.0f];
}

- (void)showToastToView:(UIView *)view from:(UIView *)sourceView withRoundedCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius
{
    UIRectCorner corner = 0; //holds the corner
    
    // Determine which corner(s) should be changed
    if (tl) {
        corner = corner | UIRectCornerTopLeft;
    }
    
    if (tr) {
        corner = corner | UIRectCornerTopRight;
    }
    
    if (bl) {
        corner = corner | UIRectCornerBottomLeft;
    }
    
    if (br) {
        corner = corner | UIRectCornerBottomRight;
    }
    
    UIView *roundedView     = self;
    UIBezierPath *maskPath  = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame         = roundedView.bounds;
    maskLayer.path          = maskPath.CGPath;
    roundedView.layer.mask  = maskLayer;
    
    // acnhoring calculations
    // to do: automatically calculate anchoring from position
    
    // set container view frame
    CGRect frame = self.frame;
    
    if ([view isEqual:sourceView]) {
        frame.origin.y   = 0.0f;
        frame.origin.x   = 0.0f;
        frame.size.width = view.frame.size.width;
    } else {
        frame.origin.y   = sourceView.frame.origin.y;
        frame.origin.x   = sourceView.frame.origin.x + sourceView.frame.size.width + 10.0f;
        frame.size.width = [UIScreen mainScreen].bounds.size.width - frame.origin.x - 10.0f;
    }
    
    // get the message frame from the calculated anchor point
    CGRect messageFrame       = [self.message boundingRectWithSize:CGSizeMake(frame.size.width - 45.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:self.toastLabel.font } context:nil];
    
    // adjust the current container frame with offsets (10.0f)
    frame.size.height         = messageFrame.size.height + 10.0f;
    
    self.frame                = frame;
    
    // set the background view frame
    frame                     = self.backgroundView.frame;
    frame.size                = self.frame.size;
    
    self.backgroundView.frame = frame;
    
    // set label frame
    frame                     = self.toastLabel.frame;
    frame.size                = messageFrame.size;
    
    self.toastLabel.frame     = frame;
    
    [view addSubview:self];
    
    [UIView animateWithDuration:self.fadeTime/2 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(fadeOut) withObject:nil afterDelay:self.displayTime];
        }
    }];
}

@end
