//
//  ScreenMeetToast.h
//  Remember The Date
//
//  Created by Adrian Cayaco on 15/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  ScreenMeetToast;

@protocol ScreenMeetToastDelegate <NSObject>

@optional

- (void)SMToastWillBeRemovedFromView:(ScreenMeetToast *)screenMeetToast;
- (void)SMToastWasRemovedFromView:(ScreenMeetToast *)screenMeetToast;

@end

@interface ScreenMeetToast : UIView

@property (assign, nonatomic) id<ScreenMeetToastDelegate> delegate;

@property (assign, nonatomic) CGFloat   fadeTime;
@property (assign, nonatomic) CGFloat   displayTime;

@property (strong, nonatomic) NSString  *message;
@property (strong, nonatomic) UIView    *backgroundView;
@property (strong, nonatomic) UIImage   *toastIcon;

+ (id)roundCornersOnView:(id)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;

- (instancetype)initWithMessage:(NSString *)message andFrame:(CGRect)frame;
- (instancetype)initWithMessage:(NSString *)message;


- (void)showToastToView:(UIView *)view from:(UIView *)sourceView;
- (void)showToastToView:(UIView *)view from:(UIView *)sourceView withRoundedCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;

@end
