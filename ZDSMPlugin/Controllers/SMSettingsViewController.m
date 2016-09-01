//
//  SMSettingsViewController.m
//  GServices
//
//  Created by Adrian Cayaco on 20/07/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

#import "SMSettingsViewController.h"

#import "ZDSMPluginManager.h"
#import <ScreenMeetSDK/ScreenMeetSDK-Swift.h>

@interface SMSettingsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIView            *containerView;
@property (strong, nonatomic) NSMutableArray    *customConstraints;

@property (strong, nonatomic) NSString          *roomPassword;

@property (weak, nonatomic) IBOutlet UISwitch           *askNameSwitch;
@property (weak, nonatomic) IBOutlet UISlider           *qualitySlider;

@property (weak, nonatomic) IBOutlet UIButton           *roomNameButton;
@property (weak, nonatomic) IBOutlet UIButton           *roomPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton           *accountNameButton;
@property (weak, nonatomic) IBOutlet UIButton           *emailNameButton;
@property (weak, nonatomic) IBOutlet UIButton           *changePasswordButton;
@property (weak, nonatomic) IBOutlet UIButton           *logoutButton;

@property (weak, nonatomic) IBOutlet UILabel            *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel            *roomPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel            *accountNameLabel;
@property (weak, nonatomic) IBOutlet UILabel            *emailLabel;

@property (strong, nonatomic) UIAlertController         *changePasswordAlert;

@end

@implementation SMSettingsViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _customConstraints  = [[NSMutableArray alloc] init];
    
    UIView *view        = nil;
    NSArray *objects    = [[NSBundle mainBundle] loadNibNamed:@"GGCoverViewController" owner:self options:nil];
    
    for (id object in objects) {
        if ([object isKindOfClass:[UIView class]]) {
            view = object;
            break;
        }
    }
    
    if (view != nil) {
        
        _containerView                                  = view;
        _containerView.multipleTouchEnabled             = YES;
        _containerView.userInteractionEnabled           = YES;
        
        self.view.userInteractionEnabled                = YES;
        self.view.multipleTouchEnabled                  = YES;
        view.translatesAutoresizingMaskIntoConstraints  = NO;
        
        [self.view addSubview:view];
        
        [self.view setNeedsUpdateConstraints];
        
    }
}

- (void)updateConstraints
{
    [self.view removeConstraints:self.customConstraints];
    [self.customConstraints removeAllObjects];
    
    if (self.containerView != nil) {
        UIView *view = self.containerView;
        NSDictionary *views = NSDictionaryOfVariableBindings(view);
        
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"H:|[view]|" options:0 metrics:nil views:views]];
        [self.customConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:
          @"V:|[view]|" options:0 metrics:nil views:views]];
        
        [self.view addConstraints:self.customConstraints];
    }
    
    [super.view updateConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.navigationItem.hidesBackButton       = YES;
    self.navigationItem.leftBarButtonItem     = [ZDSMPluginManager createCloseButtonItemWithTarget:self forSelector:@selector(closeButtonWasPressed)];

    self.roomPassword                         = @"";
    self.roomNameLabel.text                   = [[ScreenMeet sharedInstance] getRoomName];
    self.askNameSwitch.on                     = [[[ScreenMeet sharedInstance] getMeetingConfig] askForName];

    [self.askNameSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.qualitySlider.maximumValue           = 100.0f;
    self.qualitySlider.minimumValue           = 1.0f;
    self.qualitySlider.value                  = [[ScreenMeet sharedInstance] getQuality];
    self.qualitySlider.continuous             = NO;
    [self.qualitySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    if ([[[ScreenMeet sharedInstance] getMeetingConfig] password]) {
        self.roomPasswordLabel.text = [[[ScreenMeet sharedInstance] getMeetingConfig] password];
    } else {
        self.roomPasswordLabel.text = @"none";
    }
    
    self.accountNameLabel.text = [[ScreenMeet sharedInstance] getUserName];
    self.emailLabel.text       = [[ScreenMeet sharedInstance] getUserEmail];
    
    
    [self.roomPasswordButton addTarget:self action:@selector(roomPasswordButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.roomNameButton addTarget:self action:@selector(roomNameButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.accountNameButton addTarget:self action:@selector(accountNameButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.emailNameButton addTarget:self action:@selector(emailButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton addTarget:self action:@selector(logoutButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.changePasswordButton addTarget:self action:@selector(changePasswordButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (void)closeButtonWasPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)roomNameButtonWasPressed
{
    UIAlertController *roomNameAlert = [UIAlertController alertControllerWithTitle:@"Room Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [roomNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Room Name", @"Room Name");
         textField.text        = [[ScreenMeet sharedInstance] getRoomName];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [roomNameAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"SAVE", @"Save action")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action)
                                 {
                                     NSLog(@"Room name action");
                                     [[ScreenMeet sharedInstance] setRoomName:roomNameAlert.textFields[0].text callback:^(enum CallStatus status) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (status == CallStatusSUCCESS) {
                                                 self.roomNameLabel.text = roomNameAlert.textFields[0].text;
                                                 [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                                             message:[NSString stringWithFormat:@"Room Name changed to: %@", roomNameAlert.textFields[0].text]
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Ok"
                                                                   otherButtonTitles:nil] show];
                                             } else {
                                                 [[ZDSMPluginManager sharedManager] showDefaultError];
                                             }
                                         });
                                     }];
                                 }];
    
    [roomNameAlert addAction:cancelAction];
    [roomNameAlert addAction:saveAction];
    
    [self presentViewController:roomNameAlert animated:YES completion:nil];
}

- (void)roomPasswordButtonWasPressed
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Room Password" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"none" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:NO completion:nil];
        
        // actions
        self.roomPassword = nil;
        
        [[ScreenMeet sharedInstance] setMeetingConfig:self.roomPassword askForName:self.askNameSwitch.isOn callback:^(enum CallStatus status) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == CallStatusSUCCESS) {
                    self.roomPasswordLabel.text = @"none";
                    [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                message:[NSString stringWithFormat:@"Room password was removed."]
                                               delegate:self
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil] show];
                } else {
                    [[ZDSMPluginManager sharedManager] showDefaultError];
                }
            });
        }];
    }];
    
    UIAlertAction *customAction = [UIAlertAction actionWithTitle:@"custom" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:NO completion:nil];
        
        // actions
        UIAlertController *setRoomPasswordAlert = [UIAlertController alertControllerWithTitle:@"Room Password" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [setRoomPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"Room Password", @"Password");
             textField.secureTextEntry = YES;
             
         }];
        
        [setRoomPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = NSLocalizedString(@"Confirm Password", @"Password");
             textField.secureTextEntry = YES;
             
             [textField addTarget:self
                           action:@selector(alertTextFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
         }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           [setRoomPasswordAlert dismissViewControllerAnimated:NO completion:nil];
                                       }];
        
        UIAlertAction *saveAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"SAVE", @"Save room name password action")
                                     style:UIAlertActionStyleDestructive
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSLog(@"Set room password action");
                                         [[ScreenMeet sharedInstance] setMeetingConfig:setRoomPasswordAlert.textFields[0].text askForName:self.askNameSwitch.isOn callback:^(enum CallStatus status) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (status == CallStatusSUCCESS) {
                                                     self.roomPassword = setRoomPasswordAlert.textFields[0].text;
                                                     self.roomPasswordLabel.text = self.roomPassword;
                                                     
                                                     [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                                                 message:[NSString stringWithFormat:@"Room password was set."]
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil] show];
                                                 } else {
                                                     [[ZDSMPluginManager sharedManager] showDefaultError];
                                                 }
                                             });
                                         }];
                                     }];
        saveAction.enabled = NO;
        
        [setRoomPasswordAlert addAction:cancelAction];
        [setRoomPasswordAlert addAction:saveAction];
        
        [self presentViewController:setRoomPasswordAlert animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:NO completion:nil];
    }];

    [alert addAction:noneAction];
    [alert addAction:customAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)accountNameButtonWasPressed
{
    UIAlertController *accountNameAlert = [UIAlertController alertControllerWithTitle:@"Account Name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [accountNameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Account Name", @"Room Name");
         textField.text        = [[ScreenMeet sharedInstance] getUserName];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [accountNameAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"SAVE", @"Save account name action")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action)
                                 {
                                     NSLog(@"Account Name action");
                                     [[ScreenMeet sharedInstance] updateUser:nil username:self.accountNameLabel.text password:nil callback:^(enum CallStatus status) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             if (status == CallStatusSUCCESS) {
                                                 
                                                 self.accountNameLabel.text = accountNameAlert.textFields[0].text;
                                                 
                                                 [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                                             message:[NSString stringWithFormat:@"Account Name changed to: %@", self.accountNameLabel.text]
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Ok"
                                                                   otherButtonTitles:nil] show];
                                             } else {
                                                 [[ZDSMPluginManager sharedManager] showDefaultError];
                                             }
                                         });
                                     }];
                                 }];
    
    [accountNameAlert addAction:cancelAction];
    [accountNameAlert addAction:saveAction];
    
    [self presentViewController:accountNameAlert animated:YES completion:nil];
}

- (void)emailButtonWasPressed
{
    UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:@"Email" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [emailAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Email", @"Email");
         textField.text        = [[ScreenMeet sharedInstance] getUserEmail];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [emailAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    
    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"SAVE", @"Save email action")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action)
                                 {
                                     NSLog(@"Email action");
                                     
                                     [[ScreenMeet sharedInstance] updateUser:emailAlert.textFields[0].text username:nil password:nil callback:^(enum CallStatus status) {
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             if (status == CallStatusSUCCESS) {
                                                 
                                                 self.emailLabel.text = emailAlert.textFields[0].text;
                                                 
                                                 [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                                             message:[NSString stringWithFormat:@"Email changed to: %@", self.emailLabel.text]
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Ok"
                                                                   otherButtonTitles:nil] show];
                                             } else {
                                                 [[ZDSMPluginManager sharedManager] showDefaultError];
                                             }
                                         });
                                         
                                     }];
                                 }];
    
    [emailAlert addAction:cancelAction];
    [emailAlert addAction:saveAction];
    
    [self presentViewController:emailAlert animated:YES completion:nil];
}

- (void)changePasswordButtonWasPressed
{
    
    self.changePasswordAlert = [UIAlertController alertControllerWithTitle:@"Change Password" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [self.changePasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"New Password", @"Password");
         textField.secureTextEntry = YES;
         
     }];
    
    [self.changePasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Confirm Password", @"Password");
         textField.secureTextEntry = YES;
         
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [self.changePasswordAlert dismissViewControllerAnimated:NO completion:nil];
                                   }];
    UIAlertAction *saveAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"SAVE", @"Reset action")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction *action)
                                 {
                                     NSLog(@"Change password action");
                                     [self.changePasswordAlert dismissViewControllerAnimated:NO completion:nil];
                                     [[ScreenMeet sharedInstance] updateUser:nil username:nil password:self.changePasswordAlert.textFields[0].text callback:^(enum CallStatus status) {
                                         if (status == CallStatusSUCCESS) {
                                             [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                                         message:[NSString stringWithFormat:@"Password changed."]
                                                                        delegate:self
                                                               cancelButtonTitle:@"Ok"
                                                               otherButtonTitles:nil] show];
                                         } else {
                                             [[ZDSMPluginManager sharedManager] showDefaultError];
                                         }
                                     }];
                                 }];
    saveAction.enabled = NO;
    
    [self.changePasswordAlert addAction:cancelAction];
    [self.changePasswordAlert addAction:saveAction];
    
    [self presentViewController:self.changePasswordAlert animated:YES completion:nil];
}

- (void)logoutButtonWasPressed
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[ZDSMPluginManager sharedManager] logout];
    }];
}

#pragma mark - UISwitch Delegate

- (void)switchValueChanged:(id)sender
{
    [[ScreenMeet sharedInstance] setMeetingConfig:nil askForName:self.askNameSwitch.isOn callback:^(enum CallStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == CallStatusSUCCESS) {
                [[[UIAlertView alloc] initWithTitle:@"Success!"
                                            message:[NSString stringWithFormat:@"Ask for name is now %@.", self.askNameSwitch.isOn ? @"on" : @"off"]
                                           delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            } else {
                [[ZDSMPluginManager sharedManager] showDefaultError];
            }
        });
    }];
}

#pragma mark - UISlider Delegate

- (void)sliderValueChanged:(id)sender
{
    UISlider *slider = sender;
    slider.value = roundf(slider.value);
    
    NSLog(@"Slider value: %f", slider.value);
    
    [[ScreenMeet sharedInstance] setQuality:slider.value];
}


#pragma mark - UITextField Delegate

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *newPassword     = alertController.textFields.firstObject;
        UITextField *confirmPassword = alertController.textFields.lastObject;
        UIAlertAction *resetAction   = alertController.actions.lastObject;
        resetAction.enabled          = [newPassword.text isEqualToString:confirmPassword.text];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if (textField == self.roomName) {
//        return ([string rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location == NSNotFound);
//    } else {
//        return YES;
//    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
