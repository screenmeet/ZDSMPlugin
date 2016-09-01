//
//  ScreenMeetChatContainer.h
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 16/08/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenMeetChatWidget.h"

@interface ScreenMeetChatContainer : UIView

@property (strong, nonatomic) NSMutableArray       *messageQueue;

@property (weak, nonatomic) ScreenMeetChatWidget *widget;

- (void)addStackableToastMessage:(NSString *)message;

@end
