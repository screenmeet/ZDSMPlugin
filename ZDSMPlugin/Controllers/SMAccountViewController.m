//
//  SMAccountViewController.m
//  GServices
//
//  Created by Adrian Cayaco on 20/07/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

#import "SMAccountViewController.h"

#import "ScreenMeetManager.h"
#import <ScreenMeetSDK/ScreenMeetSDK-Swift.h>

@interface SMAccountViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIView            *containerView;
@property (strong, nonatomic) NSMutableArray    *customConstraints;

@property (strong, nonatomic) UIAlertController         *changePasswordAlert;

@property (weak, nonatomic) IBOutlet UITextField        *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField        *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton           *changePasswordButton;

@end

@implementation SMAccountViewController

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
    
    self.navigationItem.hidesBackButton       = YES;
    self.navigationItem.leftBarButtonItem     = [ScreenMeetManager createCloseButtonItemWithTarget:self forSelector:@selector(closeButtonWasPressed)];
    
    self.nameTextField.text = [[ScreenMeet sharedInstance] getUserName];
    self.emailTextField.text = [[ScreenMeet sharedInstance] getUserEmail];
    
    [self.changePasswordButton addTarget:self action:@selector(changePasswordButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

- (void)changePasswordButtonWasPressed:(UIButton *)button
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
                                           [[ScreenMeetManager sharedManager] showDefaultError];
                                       }
                                   }];
                               }];
    saveAction.enabled = NO;
    
    [self.changePasswordAlert addAction:cancelAction];
    [self.changePasswordAlert addAction:saveAction];
    
    [self presentViewController:self.changePasswordAlert animated:YES completion:nil];
}

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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        
        [[ScreenMeet sharedInstance] updateUser:nil username:self.nameTextField.text password:nil callback:^(enum CallStatus status) {
            if (status == CallStatusSUCCESS) {
                [[[UIAlertView alloc] initWithTitle:@"Success!"
                                           message:[NSString stringWithFormat:@"Name changed to: %@", self.nameTextField.text]
                                          delegate:self
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil] show];
            } else {
                [[ScreenMeetManager sharedManager] showDefaultError];
            }
        }];
        
    } else if (textField == self.emailTextField) {
        
        [[ScreenMeet sharedInstance] updateUser:self.emailTextField.text username:nil password:nil callback:^(enum CallStatus status) {
            
            if (status == CallStatusSUCCESS) {
                [[[UIAlertView alloc] initWithTitle:@"Success!"
                                            message:[NSString stringWithFormat:@"Email changed to: %@", self.emailTextField.text]
                                           delegate:self
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            } else {
                [[ScreenMeetManager sharedManager] showDefaultError];
            }
            
        }];
        
    }
    
    [textField resignFirstResponder];
    return NO;
}

@end
