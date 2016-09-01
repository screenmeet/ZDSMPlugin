//
//  SMChatWidget.h
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 14/08/2016.
//  Copyright © 2016 ScreenMeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMChatWidget : UIView

@property (assign, nonatomic) BOOL isLive;
@property (assign, nonatomic) BOOL willFlipContainer;
@property (assign, nonatomic, readonly) BOOL isActive;

// to refresh UI
- (void)updateUI;

// set different UI
- (void)showDefaultUI;
- (void)showLiveUI;
- (void)showStreamingUI;


- (void)showWidget;
- (void)hideWidget;

- (void)activateChat;
- (void)endChat;

// add a message to be shown as a toast
- (void)addStackableToastMessage:(NSString *)message;

@end
