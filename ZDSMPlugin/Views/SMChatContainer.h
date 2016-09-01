//
//  SMChatContainer.h
//  ZDSMPlugin
//
//  Created by Adrian Cayaco on 16/08/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMChatWidget.h"

@interface SMChatContainer : UIView

@property (strong, nonatomic) NSMutableArray       *messageQueue;

@property (weak, nonatomic) SMChatWidget *widget;

- (void)addStackableToastMessage:(NSString *)message;

@end
