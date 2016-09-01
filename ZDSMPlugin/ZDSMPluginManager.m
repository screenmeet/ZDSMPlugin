//
//  ZDSMPluginManager.m
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 13/07/2016.
//  Copyright © 2016 ScreenMeet. All rights reserved.
//


#import "ZDSMPluginManager.h"

#import "SMSettingsViewController.h"
#import "SMAccountViewController.h"
#import "SMMessagesViewController.h"

// From Pods
#import <MBProgressHUD/MBProgressHUD.h>

// Zendesk SDK
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskSDK/ZDKSupportView.h>
#import <ZDCChat/ZDCChat.h>

#define kChatWidgetTag 2001

static NSString *SM_API_KEY_SB       = @"19ef50c67e8648f08dfc4702f992159d";
static NSString *SM_API_KEY_PROD     = @"f6b5eda921c749968fa4cd240e7fbe1c";

static NSString *ZENDESK_APP_ID      = @"8ecc5e5b0177e72437db6ee0c0889ea6b87023348faeb750";
static NSString *ZENDESK_URL         = @"https://screenmeetdev.zendesk.com";
static NSString *ZENDESK_CLIENT_ID   = @"mobile_sdk_client_a224f34d64dae33a666a";
static NSString *ZENDESK_ACCOUNT_KEY = @"476NiNORvNGOc4WSDE87u8zKNUvtYxBx";

NSString * const APNS_ID_KEY  = @"APNS_ID_KEY";

@interface ZDSMPluginManager () <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString      *token;
@property (strong, nonatomic) NSString      *username;
@property (strong, nonatomic) NSString      *password;

@property (strong, nonatomic) UIAlertView   *tokenAlert;
@property (strong, nonatomic) UIAlertView   *usernameAlert;

@property (assign, nonatomic) BOOL          isProduction;

@end

@implementation ZDSMPluginManager

static ZDSMPluginManager *manager = nil;

+ (ZDSMPluginManager *)sharedManager
{
    @synchronized(self) {
        if (!manager) {
            manager = (ZDSMPluginManager *)[[self alloc] init];
        }
    }
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self initiateScreenMeetinProd:NO];
        [self initialzeZendesk];
    }
    
    return self;
}

#pragma mark - Accessors

- (SMMessagesViewController *)messagesVC {
    if (!_messagesVC) {
        _messagesVC = [SMMessagesViewController messagesViewController];
    }
    return _messagesVC;
}

- (SMChatWidget *)chatWidget
{
    if (!_chatWidget) {
        _chatWidget = [[SMChatWidget alloc] initWithFrame:CGRectMake(10.0f, [UIScreen mainScreen].bounds.size.height - 100.0f, 40.0f, 40.0f)];
        _chatWidget.tag = kChatWidgetTag;
    }
    return _chatWidget;
}

#pragma mark - Class Methods

+ (UIBarButtonItem *)createCloseButtonItemWithTarget:(id)target forSelector:(SEL)action
{
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [tempButton setFrame:CGRectMake(0, 0, 24.0f, 24.0f)];
    [tempButton setTitle:@"<" forState:UIControlStateNormal];
    [tempButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [tempButton setTintColor:[UIColor blueColor]];
    
    [tempButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:tempButton];
    
    return button;
}

+ (void)presentViewControllerFromWindowRootViewController:(id)viewController animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (viewController) {
        [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:viewController animated:flag completion:completion];
    }
}

#pragma mark - Private Methods

- (void)initiateScreenMeetinProd:(BOOL)inProd
{
    
    self.isProduction = inProd;
    
    //
    // Initialize ScreenMeet SDK
    //
    
    if (inProd) {
        [ScreenMeet initSharedInstance:SM_API_KEY_PROD environment:EnvironmentTypePRODUCTION];
    } else {
        [ScreenMeet initSharedInstance:SM_API_KEY_SB environment:EnvironmentTypeSANDBOX];
    }
}

- (void)initialzeZendesk
{
    //
    // Enable logging for debug builds
    //
    
#ifdef DEBUG
    [ZDKLogger enable:YES];
#else
    [ZDKLogger enable:NO];
#endif
    
    //
    // Initialize the Zendesk SDK
    //
    
    [[ZDKConfig instance] initializeWithAppId:ZENDESK_APP_ID
                                   zendeskUrl:ZENDESK_URL
                                     clientId:ZENDESK_CLIENT_ID];
    
    //
    // Initialise the chat SDK
    //
    [ZDCChat configure:^(ZDCConfig *defaults) {
        defaults.accountKey                         = ZENDESK_ACCOUNT_KEY;
        defaults.preChatDataRequirements.department = ZDCPreChatDataOptional;
        defaults.preChatDataRequirements.message    = ZDCPreChatDataOptional;
    }];
    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //

}

- (void)handleDoubleTap
{
    [self showMenu];
}

- (void)showMenu
{
    NSString *menuTitle = @"None";
    
    if ([ScreenMeet sharedInstance]) {
        if (self.isProduction) {
            menuTitle = @"ScreenMeet (Production)";
        } else {
            menuTitle = @"ScreenMeet (Sandbox)";
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:menuTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([[ScreenMeet sharedInstance] isUserLoggedIn]) {
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
            
            // actions
            [self logout];
        }];
        
        [alert addAction:logoutAction];
        
        switch ([[ScreenMeet sharedInstance] getStreamState]) {
            case StreamStateTypeACTIVE: {
                
                UIAlertAction *stopStreamingAction = [UIAlertAction actionWithTitle:@"Stop Streaming" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                    
                    // actions
                    [self stopStream];
                }];
                
                
                [alert addAction:stopStreamingAction];
                
                UIAlertAction *pauseStreamAction = [UIAlertAction actionWithTitle:@"Pause Streaming" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                    
                    // actions
                    [self pauseStream];
                }];
                
                [alert addAction:pauseStreamAction];
                
                break;
            }
            case StreamStateTypePAUSED: {
                
                UIAlertAction *stopStreamingAction = [UIAlertAction actionWithTitle:@"Stop Streaming" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                    
                    // actions
                    [self stopStream];
                }];
                
                
                [alert addAction:stopStreamingAction];
                
                UIAlertAction *resumeStreamingAction = [UIAlertAction actionWithTitle:@"Resume Streaming" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                    
                    // actions
                    [self resumeStream];
                }];
                
                [alert addAction:resumeStreamingAction];
                
                break;
            }
            case  StreamStateTypeSTOPPED:
            default: {
                
                
                UIAlertAction *startStreamingAction = [UIAlertAction actionWithTitle:@"Start Streaming" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:NO completion:nil];
                    
                    // actions
                    [self startStream:^(NSInteger status) {
                        if (status == CallStatusSUCCESS) {
                            NSLog(@"Stream started...");
                        } else {
                            [self showDefaultError];
                        }
                    }];
                }];
                
                [alert addAction:startStreamingAction];
                
                break;
            }
        }
        
        UIAlertAction *showURLAction = [UIAlertAction actionWithTitle:@"Show URL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[ScreenMeet sharedInstance] getRoomUrl] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        }];
        
        [alert addAction:showURLAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[[SMSettingsViewController alloc] init]];
            
            [ZDSMPluginManager presentViewControllerFromWindowRootViewController:navVC animated:YES completion:^{
                
            }];
        }];
        
        [alert addAction:settingsAction];

    } else {
        if ([ScreenMeet sharedInstance]) {
            UIAlertAction *loginWithTokenAction = [UIAlertAction actionWithTitle:@"Login with Token" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:NO completion:nil];
                
                self.tokenAlert = [[UIAlertView alloc] initWithTitle:@"Enter Token" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login",nil];
                self.tokenAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
                [self.tokenAlert show];
            }];
            
            
            UIAlertAction *loginWithUsernameAction = [UIAlertAction actionWithTitle:@"Login with Username" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:NO completion:nil];
                
                self.usernameAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Please enter your username and password:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
                
                self.usernameAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                
                [self.usernameAlert show];
            }];
            
            [alert addAction:loginWithTokenAction];
            [alert addAction:loginWithUsernameAction];
        } else {
            UIAlertAction *chooseProductionAction = [UIAlertAction actionWithTitle:@"Production" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:NO completion:nil];
                
                self.isProduction = YES;
                
                [self initiateScreenMeetinProd:self.isProduction];
            }];
            
            
            UIAlertAction *chooseSandboxAction = [UIAlertAction actionWithTitle:@"Sandbox" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:NO completion:nil];
                
                self.isProduction = NO;
            
                [self initiateScreenMeetinProd:self.isProduction];
            }];
            
            [alert addAction:chooseProductionAction];
            [alert addAction:chooseSandboxAction];
        }
    }
    
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:NO completion:nil];
    }];
    
    [alert addAction:exitAction];
    
    id rootVC = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    [rootVC presentViewController:alert animated:YES completion:^{
        
    }];
}

#pragma mark - Public Methods

- (BOOL)isChatWidgetInitialized
{
    if ([[[UIApplication sharedApplication] delegate].window viewWithTag:kChatWidgetTag]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)initializeChatWidget
{
    if (![self isChatWidgetInitialized]) {
        [[[UIApplication sharedApplication] delegate].window addSubview:self.chatWidget];
    }
    
    [[[UIApplication sharedApplication] delegate].window bringSubviewToFront:self.chatWidget];
}

- (void)showHUDWithTitle:(NSString *)title
{
    if (!self.hud) {
        self.hud                 = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
        self.hud.label.text      = title;
        self.hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.30f];
    } else {
        self.hud.label.text      = title;
    }
}

- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] delegate].window animated:YES];
    self.hud = nil;
}

- (void)showWelcomeDialog
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Welcome"
                                                        message:[[ScreenMeet sharedInstance] getUserName]
                                                       delegate:self
                                              cancelButtonTitle:@"close"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)showDefaultError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"Oops something went wrong"
                                                delegate:self
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    [alertView show];
}

- (void)loginWithToken:(NSString *)token
{
    [[ScreenMeet sharedInstance] authenticate:token callback:^(enum CallStatus status) {
        if (status == CallStatusSUCCESS) {
            // logged in
            [self showWelcomeDialog];
        } else {
            [self showDefaultError];
        }
    }];
}

- (void)loginWithToken:(NSString *)token callback:(void (^)(enum CallStatus status))callback
{
    [[ScreenMeet sharedInstance] authenticate:token callback:callback];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [[ScreenMeet sharedInstance] authenticate:username password:password callback:^(enum CallStatus status) {
        if (status == CallStatusSUCCESS) {
            [self showWelcomeDialog];
        } else {
            [self showDefaultError];
        }
    }];
}

- (void)logout
{
    [[ScreenMeet sharedInstance] logoutUser];
}

- (void)startStream:(void (^)(NSInteger status))callback
{
    [[ScreenMeet sharedInstance] startStream:^(enum CallStatus status) {
        callback(status);
    }];
}

- (void)stopStream
{
    [[ScreenMeet sharedInstance] stopStream];
    NSLog(@"Stream stopped...");
}

- (void)pauseStream
{
    [[ScreenMeet sharedInstance] pauseStream];
    NSLog(@"Stream paused...");
}

- (void)resumeStream
{
    [[ScreenMeet sharedInstance] resumeStream];
    NSLog(@"Stream resumed...");
}

- (BOOL)isStreaming
{
    switch ([[ScreenMeet sharedInstance] getStreamState]) {
        case StreamStateTypeACTIVE:
        case StreamStateTypePAUSED:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.tokenAlert) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.token = [alertView textFieldAtIndex:0].text;
            [self loginWithToken:self.token];
        }
    } else if (alertView == self.usernameAlert) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.username = [alertView textFieldAtIndex:0].text;
            self.password = [alertView textFieldAtIndex:1].text;
            
            [self loginWithUsername:self.username andPassword:self.password];
        }
    }
}

@end
