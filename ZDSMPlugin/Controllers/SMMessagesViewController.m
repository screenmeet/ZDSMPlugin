//
//  SMMessagesViewController.m
//  ZDSMPlugin
//
//  Created by Mylene Bayan on 22/08/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

#import "SMMessagesViewController.h"

#import <ZendeskSDK/ZendeskSDK.h>
#import <ZDCChat/ZDCChat.h>

#import "JSQMessages.h"

#import "ZDSMPluginManager.h"

#define AVATAR_SIZE 28.0

@interface SMMessagesViewController ()

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *eventIds;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (assign, nonatomic) BOOL isAvatarLoaded;

@end

@implementation SMMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize avatarSize = CGSizeMake(AVATAR_SIZE, AVATAR_SIZE);
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = avatarSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = avatarSize;
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightLight];
    self.collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(5.0, 7.0, 5.0, 3.0);
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:233.0/255.0 alpha:1.0]];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:246.0/255.0 alpha:1.0]];
    
    self.messages = [NSMutableArray new];
    self.eventIds = [NSMutableDictionary new];
    
    self.senderId          = @"screenmeet_customer_sender_id";
    self.senderDisplayName = @"Visitor";
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.isAvatarLoaded = NO;
    
    [[ZDCChat instance].session connect];
    
    [[ZDCChat instance].session removeObserverForTimeoutEvents:self];
    [[ZDCChat instance].session addObserver:self forTimeoutEvents:@selector(timeoutEvent:)];
    
    [[ZDCChat instance].session.dataSource removeObserverForChatLogEvents:self];
    [[ZDCChat instance].session.dataSource addObserver:self forChatLogEvents:@selector(chatEvent:)];
    
    [[ZDCChat instance].session.dataSource removeObserverForAgentEvents:self];
    [[ZDCChat instance].session.dataSource addObserver:self forAgentEvents:@selector(agentEvent:)];
    
    [ZDSMPluginManager sharedManager].chatWidget.isLive = YES;
    
    [self verifyEvents];
    
    self.navigationItem.leftBarButtonItem = [ZDSMPluginManager createCloseButtonItemWithTarget:self forSelector:@selector(closeButtonWasPressed:)];
    
    [self processRightBarButtonItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Override

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    NSLog(@"Session status: %lul", (unsigned long)[[ZDCChat instance].session status]);
    
    [self sendMessage:text];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.avatarImageView.hidden = [self isLeadMessage:indexPath] ? NO : YES;
    
    JSQMessage *message = self.messages[indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName : cell.textView.textColor,
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    return cell;
}

#pragma mark - JSQMessages CollectionView DataSource
-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = self.messages[indexPath.item];
    
    if ([self isLeadMessage:indexPath]) {
        if ([message.senderId isEqualToString:self.senderId]) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths firstObject];
            NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.png"];
            UIImage *image = [UIImage imageWithContentsOfFile:getImagePath];
            
            if (image != nil){
                return [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                  diameter:AVATAR_SIZE];;
            }
        }
    }
    
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self isLeadMessage:indexPath] ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0.0;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isLeadMessage:indexPath]) {
        JSQMessage *message = self.messages[indexPath.item];
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName
                                               attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    
    return nil;
}

- (NSURL *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isLeadMessage:indexPath]) {
        JSQMessage *message = self.messages[indexPath.item];
        if (![message.senderId isEqualToString:self.senderId]) {
            ZDCChatAgent *agent = [[ZDCChat instance].session.dataSource agentForNickname:message.senderId];
            NSLog(@"Delegate AvatarURL: %@", agent.avatarURL);
            return [NSURL URLWithString:agent.avatarURL];
        }
    }
    
    return nil;
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (![textView.text isEqualToString:@""]) {
            [self sendMessage:textView.text];
        }
        return NO;
    }
    return YES;
}

#pragma mark - ZDCChat Events
- (void)verifyEvents
{
    NSMutableArray *chatLog = [[ZDCChat instance].session.dataSource livechatLog];
    
    for (ZDCChatEvent *chatEvent in chatLog) {
        self.eventIds[chatEvent.eventId] = @1;
    }
}

- (void)chatEvent:(NSNotification *)notification
{
    ZDCChatEvent *chatEvent = [[ZDCChat instance].session.dataSource livechatLog].lastObject;
    
    // only show messages for events verified by the server
    // we can also add here timestamp filters
    
    NSLog(@"Chat Event Type: %lu", (unsigned long)chatEvent.type);
    
    if (chatEvent.type == ZDCChatEventTypeMemberLeave) {
        if ([[ZDCChat instance].session status] != ZDCChatSessionStatusInactive) {
            
            [ZDSMPluginManager sharedManager].chatWidget.isLive = NO;
            [[ZDSMPluginManager sharedManager].chatWidget endChat];
            
            UIAlertController *endChatAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"%@ ended the chat.", chatEvent.displayName] preferredStyle:UIAlertControllerStyleAlert];
            [endChatAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self endChatAndDismiss];
            }]];
            
            if (self.isViewLoaded && self.view.window) {
                [self presentViewController:endChatAlert animated:YES completion:nil];
            } else {
                [ZDSMPluginManager presentViewControllerFromWindowRootViewController:endChatAlert animated:YES completion:^{
                    
                }];
            }
        }
        
    } else if (chatEvent.verified && ![self.eventIds[chatEvent.eventId] boolValue]) {
        
        self.eventIds[chatEvent.eventId] = @1;
        
        NSString *senderId = @"";
        
        if (chatEvent.type == ZDCChatEventTypeAgentMessage) {
            senderId          = chatEvent.nickname;
        } else {
            senderId          = self.senderId;
        }
        
        // Check message
        NSString *text = @"";
        
        if ([[chatEvent.message lowercaseString] containsString:@"requestscreenshare"]) {
            text     = @"requested a screen share...";
            
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
            long long diff         = milliseconds - [chatEvent.timestamp longLongValue];
            long long threshold    = 5000;
            
            if (diff <= threshold) {
                [self showRequestAlertforMessage:chatEvent];
            }
            
        } else if ([[chatEvent.message lowercaseString] containsString:@"stopscreenshare"]) {
            text     = @"stop the screen sharing...";
            [self stopStreamButtonWasPressed:nil];
        } else {
            text     = chatEvent.message;
        }
        
        JSQMessage *message = [JSQMessage messageWithSenderId:senderId
                                                  displayName:chatEvent.displayName
                                                         text:text];
        
        [self.messages addObject:message];
        
        [self finishReceivingMessage];
        
        if (self.isViewLoaded && self.view.window) {
            // do nothing
        } else {
            [[ZDSMPluginManager sharedManager].chatWidget addStackableToastMessage:[NSString stringWithFormat:@"%@: %@", chatEvent.displayName, message.text]];
        }
    }
}

- (void)timeoutEvent:(NSNotification *)notification {
    /* When a chat times out, you won't be able to send messages. The chat returns to the uninitialized state. You can start a new chat or inform the user the chat has ended but you cannot reconnect to the timed out chat. */
    
    [ZDSMPluginManager sharedManager].chatWidget.isLive = NO;
    [[ZDSMPluginManager sharedManager].chatWidget endChat];
    
    UIAlertController *timeoutAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Your session has timed out. Ending chat." preferredStyle:UIAlertControllerStyleAlert];
    [timeoutAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self endChatAndDismiss];
    }]];
    
    if (self.isViewLoaded && self.view.window) {
        [self presentViewController:timeoutAlert animated:YES completion:nil];
    } else {
        [ZDSMPluginManager presentViewControllerFromWindowRootViewController:timeoutAlert animated:YES completion:^{
            
        }];
    }
}

- (void)agentEvent:(NSNotification *)notification {
    /* Fix for ticket #38 "[ZD] Main chat clean-up round 3 - avatars and styling" wherein avatar does not load when resuming active chat from app relaunch.
     
     Bug Reason: Agent info is still not available even if chatEvent: is already receiving chat logs.
     
     [[ZDCChat instance].session.dataSource agentForNickname:message.senderId] from collectionView:avatarImageUrlForItemAtIndexPath: dataSource returns initially returns nil.
     
     Solution: Force reload the table view once agent info becomes available.
     
     NOTE: agentEvent: triggers multiple times as it handles even agent typing event.  A flag has been set to avoid multiple calls to [self.collectionView reloadData]
     */
    
    NSDictionary *agents = [ZDCChat instance].session.dataSource.agents;
    if (agents.count > 0 && !self.isAvatarLoaded) {
        [self.collectionView reloadData];
        self.isAvatarLoaded = YES;
    }
}

- (void)showRequestAlertforMessage:(ZDCChatEvent *)event
{
    UIAlertController *requestAlert = [UIAlertController alertControllerWithTitle:@"Screen Share" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [requestAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *shareAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Share", @"Share action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Share action");
                                      
                                      // extract token from the message
                                      // to do: add checks if valid message format
                                      
                                      NSString *token = [[event.message componentsSeparatedByString:@"|"] lastObject];
                                      
                                      [[ZDSMPluginManager sharedManager] showHUDWithTitle:@"authenticating..."];
                                      
                                      // Authenticate with token
                                      [[ZDSMPluginManager sharedManager] loginWithToken:token callback:^(enum CallStatus status) {
                                          if (status == CallStatusSUCCESS) {
                                              [self.inputToolbar.contentView.textView resignFirstResponder];
                                              NSLog(@"login with token was successful...");
                                              NSLog(@"will now start screen sharing...");
                                              
                                              [[ZDSMPluginManager sharedManager] showHUDWithTitle:@"starting stream..."];
                                              
                                              
                                              [[ScreenMeet sharedInstance] startStream:^(enum CallStatus status) {
                                                  if (status == CallStatusSUCCESS) {
                                                      NSLog(@"screen sharing now started...");
                                                      // trigger UI and states for screen sharing
                                                      
                                                      [[ZDSMPluginManager sharedManager] hideHUD];
                                                      [[ZDSMPluginManager sharedManager].chatWidget showStreamingUI];
                                                      
                                                      [self sendMessage:@"Screen shared."];
                                                      
                                                      [self processRightBarButtonItems];
                                                      
                                                      [[[UIAlertView alloc] initWithTitle:@"" message:@"Screen share started" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                                                  } else {
                                                      [self handleScreenShareError:status];
                                                  }
                                              }];
                                          } else {
                                              [self handleScreenShareError:status];
                                          }
                                      }];
                                  }];
    
    [requestAlert addAction:cancelAction];
    [requestAlert addAction:shareAction];
    
    if (self.isViewLoaded && self.view.window) {
        [self presentViewController:requestAlert animated:YES completion:nil];
    } else {
        [ZDSMPluginManager presentViewControllerFromWindowRootViewController:requestAlert animated:YES completion:^{
            
        }];
    }
}

- (void)handleScreenShareError:(CallStatus)status
{
    // can add different error handling here
    [[ZDSMPluginManager sharedManager] showDefaultError];
    [[ZDSMPluginManager sharedManager] hideHUD];
    
    // send screen share error message
    [self sendMessage:@"There was a problem with sharing my screen."];
}

- (void)sendMessage:(NSString *)text {
    
    [[ZDCChat instance].session sendChatMessage:text];
    
    [self finishSendingMessage];
}

#pragma mark - Private Methods

- (void)closeButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[ZDSMPluginManager sharedManager] initializeChatWidget];
        [[ZDSMPluginManager sharedManager].chatWidget showWidget];
    }];
}

- (void)endChatButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    NSDictionary *agents = [ZDCChat instance].session.dataSource.agents;
    
    NSString *message = @"Are you sure you wish to end this chat session";
    NSString *postfix = @"";
    
    if (agents.count > 0) {
        postfix = @" with ";
        for (NSString *aKey in [agents allKeys]) {
            ZDCChatAgent *anAgent = agents[aKey];
            postfix = [postfix stringByAppendingFormat:@"%@, ", anAgent.displayName];
        }
        
        if ([postfix length] > 0) {
            postfix = [postfix substringToIndex:[postfix length] - 2];
        } else {
            //no characters to delete... attempting to do so will result in a crash
        }
    }
    
    UIAlertController *endChatAlert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@%@?", message, postfix] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [endChatAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *shareAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"End Chat", @"Share action")
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"End Chat action");
                                      [self endChatAndDismiss];
                                  }];
    
    [endChatAlert addAction:cancelAction];
    [endChatAlert addAction:shareAction];
    
    [self presentViewController:endChatAlert animated:YES completion:nil];
}

- (void)stopStreamButtonWasPressed:(UIBarButtonItem *)barButtonItem
{
    [[ZDSMPluginManager sharedManager] stopStream];
    [[ZDSMPluginManager sharedManager].chatWidget updateUI];
    
    [self sendMessage:@"Screen sharing stoppped."];
    
    [self processRightBarButtonItems];
}

- (void)processRightBarButtonItems
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = nil;
    
    if ([[ZDSMPluginManager sharedManager] isStreaming]) {
        UIBarButtonItem *stopStream = [[UIBarButtonItem alloc] initWithTitle:@"Stop Sharing Screen" style:UIBarButtonItemStyleDone target:self action:@selector(stopStreamButtonWasPressed:)];
        UIBarButtonItem *endChat = [[UIBarButtonItem alloc] initWithTitle:@"End Chat" style:UIBarButtonItemStyleDone target:self action:@selector(endChatButtonWasPressed:)];
        
        self.navigationItem.rightBarButtonItems = @[endChat, stopStream];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End Chat" style:UIBarButtonItemStyleDone target:self action:@selector(endChatButtonWasPressed:)];
    }
}

- (BOOL)isLeadMessage:(NSIndexPath *)indexPath {
    JSQMessage *currentMessage = self.messages[indexPath.item];
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = self.messages[indexPath.item - 1];
        if ([currentMessage.senderId isEqualToString:prevMessage.senderId]) {
            return NO;
        }
    }
    return YES;
}

- (void)endChatAndDismiss {
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
    
    void (^EndChatBlock) (void) = ^(void) {
        [[ZDCChat instance].session endChat];
        
        if ([ZDSMPluginManager sharedManager].isStreaming) {
            [[ZDSMPluginManager sharedManager] stopStream];
        }
        
        if ([ZDSMPluginManager sharedManager].chatWidget.isActive) {
            [ZDSMPluginManager sharedManager].chatWidget.isLive = NO;
            [[ZDSMPluginManager sharedManager].chatWidget endChat];
        }
    
        [self.eventIds removeAllObjects];
        [self.messages removeAllObjects];
        [self.collectionView reloadData];
    };
    
    if (self.isViewLoaded && self.view.window) {
        [self dismissViewControllerAnimated:YES completion:^{
            EndChatBlock();
        }];
    } else {
        EndChatBlock();
    }
}


@end
