//
//  ZDSMPluginManager.h
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 13/07/2016.
//  Copyright © 2016 ScreenMeet. All rights reserved.
//

@class UIBarButtonItem;
@class SMMessagesViewController;
@class MBProgressHUD;

#import <Foundation/Foundation.h>

// ScreenMeet SDK
#import <ScreenMeetSDK/ScreenMeetSDK-Swift.h>

// JSQMessagesViewController
#import "SMChatWidget.h"

@interface ZDSMPluginManager : NSObject

@property (strong, nonatomic) SMChatWidget             *chatWidget;
@property (strong, nonatomic) SMMessagesViewController *messagesVC;
@property (strong, nonatomic) MBProgressHUD            *hud;

// Class Methods

+ (ZDSMPluginManager *)sharedManager;

+ (UIBarButtonItem *)createCloseButtonItemWithTarget:(id)target forSelector:(SEL)action;

+ (void)presentViewControllerFromWindowRootViewController:(id)viewController animated:(BOOL)flag completion:(void (^)(void))completion;

// Public Methods

- (BOOL)isChatWidgetInitialized;
- (BOOL)chatWindowIsVisible;

- (void)initializeChatWidget;

// Presents the SMMessagesViewController from the UIApplicationDelegate Window's RootViewController
- (void)showChatWindow:(void (^)(void))completion;

// Presents or Shows the SMMessagesViewController from the viewController
- (void)showChatWindowFromViewController:(id)viewController completion:(void (^)(void))completion;

- (void)showHUDWithTitle:(NSString *)title;
- (void)hideHUD;

- (void)showDefaultError;

// ScreenMeet SDK Methods
- (void)loginWithToken:(NSString *)token;
- (void)loginWithToken:(NSString *)token callback:(void (^)(enum CallStatus status))callback;
- (void)logout;
- (void)startStream:(void (^)(NSInteger status))callback;
- (void)stopStream;

- (BOOL)isStreaming;

@end
