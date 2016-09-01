//
//  AppDelegate.m
//  ZDSMPlugin_Example
//
//  Created by Adrian Cayaco on 01/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import "AppDelegate.h"

#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskSDK/ZDKSupportView.h>
#import <ZDCChat/ZDCChat.h>

#import "ScreenMeetManager.h"

static NSString * APP_ID      = @"8ecc5e5b0177e72437db6ee0c0889ea6b87023348faeb750";
static NSString * ZENDESK_URL = @"https://screenmeetdev.zendesk.com";
static NSString * CLIENT_ID   = @"mobile_sdk_client_a224f34d64dae33a666a";

NSString * const APNS_ID_KEY  = @"APNS_ID_KEY";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
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
    
    [[ZDKConfig instance] initializeWithAppId:APP_ID
                                   zendeskUrl:ZENDESK_URL
                                     clientId:CLIENT_ID];
    
    //
    // Initialise the chat SDK
    //
    [ZDCChat configure:^(ZDCConfig *defaults) {
        
        defaults.accountKey                         = @"476NiNORvNGOc4WSDE87u8zKNUvtYxBx";
        defaults.preChatDataRequirements.department = ZDCPreChatDataOptional;
        defaults.preChatDataRequirements.message    = ZDCPreChatDataOptional;
    }];
    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //
    
    [ScreenMeetManager sharedManager];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
